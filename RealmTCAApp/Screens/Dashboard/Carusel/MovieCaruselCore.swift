//
//  MovieCaruselCore.swift
//  RealmTCAApp
//
//  Created by Privat on 27.10.23.
//

import Foundation

import ComposableArchitecture
import RealmSwift

struct MovieCaruselEnvironment {
    
    let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    init(realm: Realm) {
        self.realm = realm
    }
}

struct MovieCarusel: Reducer {
    
    let environment = MovieCaruselEnvironment()
    
    struct State: Equatable, Codable, Hashable {
        let category: MovieSourceCategoryType
        var movies: IdentifiedArrayOf<MovieModel> = []
    }
    
    enum Action {
        case showError(AppError)
        
        case fetchMovies
        case moviesResponse(TaskResult<MoviesDto>)
        case getMoviesFromDatabase
        case updateMovie([MovieModel])
        
        case gotToMovie(MovieModel)
    }
    
    @Dependency(\.moviesClient) var movieClient
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            
            switch action {
            case .fetchMovies:
                return .run { [state = state] send in
                    switch state.category {
                    case .popular:
                        await send(.moviesResponse(.init {
                            try await self.movieClient.popularMovies()
                        }))
                    case .topRated:
                        await send(.moviesResponse(.init {
                            try await self.movieClient.topRatedMovies()
                        }))
                    }
                }
            case let .moviesResponse(result):
                switch result {
                case let .success(dto):
                    let objects = dto.results
                        .map { $0.movieObject }
                        .map {
                            if !$0.categories
                                .contains(where: { $0.category == MovieSourceCategoryType.topRated.rawValue }) {
                                let category = MovieSourceCategory()
                                category.category = state.category.rawValue
                                $0.categories.append(category)
                            }
                            return $0
                        }
                    
                    return environment.realm.save(objects).map { signal in
                        switch signal {
                        case .success:
                            return .getMoviesFromDatabase
                        case let .failure(appError):
                            return .showError(appError)
                        }
                    }
                case let .failure(error):
                    return .run { send in
                        await send(.showError(AppError.other(error)))
                    }
                }
            case .getMoviesFromDatabase:
                return environment.realm
                    .fetch(MovieObject.self)
                    .map { [state = state] results in
                        let movies = Array(results.filter { movie in
                            movie.categories.contains { category in
                                return category.category == state.category.rawValue
                            }}.map { $0.movie })
                        return .updateMovie(movies)
                    }
            case let .updateMovie(movies):
                state.movies = IdentifiedArray(uniqueElements: movies)
                return .none
            case .gotToMovie:
                return .none
            case let .showError(appError):
                print(appError)
                return .none
            }
        }
    }
}


