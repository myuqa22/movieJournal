//
//  DashboardCore.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Foundation

import ComposableArchitecture
import RealmSwift

struct DashboardEnvironment {
    
    let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    init(realm: Realm) {
        self.realm = realm
    }
}

// MARK: Reducer
struct Dashboard: Reducer {
    
    let environment = DashboardEnvironment()
    
    struct State: Equatable, Hashable, Codable {
        var path = StackState<Path.State>()
        var popularMovies: IdentifiedArrayOf<MovieModel> = []
        var topRatedMovies: IdentifiedArrayOf<MovieModel> = []
        var isLoading = false
    }
    
    enum Action {
        case goToSeen
        case goToWatchlist
        case gotToMovie(MovieModel)
        case path(StackAction<Path.State, Path.Action>)
        
        case loadPopularMovies
        case popularMoviesResponse(TaskResult<PopularMoviesDto>)
        case updatePopularMovie([MovieModel])
        case getPopularMoviesFromDatabase
        
        case loadTopRatedMovies
        case topRatedMoviesResponse(TaskResult<TopRatedMoviesDto>)
        case updateTopRatedMovies([MovieModel])
        case getTopRatedMoviesFromDatabase
    }
    
    @Dependency(\.moviesClient) var movieClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .goToSeen:
                state.path.append(.seen(.init()))
                return .none
            case .goToWatchlist:
                state.path.append(.watchlist(.init()))
                return .none
            case let .gotToMovie(movieModel):
                state.path.append(.movie(.init(movie: movieModel)))
                return .none
            case let .path(action):
                switch action {
                case let .element(id: _, action: .seen(.detailMovieButtonTapped(movie))):
                    state.path.append(.movie(.init(movie: movie)))
                    return .none
                case let .element(id: _, action: .watchlist(.detailMovieButtonTapped(movie))):
                    state.path.append(.movie(.init(movie: movie)))
                    return .none
                default:
                    return .none
                }
            case .loadPopularMovies:
                state.isLoading = true
                return .run { send in
                    await send(.popularMoviesResponse(.init {
                        try await self.movieClient.popularMovies()
                    }))
                }
            case let .popularMoviesResponse(result):
                state.isLoading = false
                switch result {
                case let .success(dto):
                    do {
                        let objects = dto.results.map { $0.movieObject }.map { movieObject in
                            if !movieObject.categories.contains(where: { $0.category == MovieSourceCategoryType.popular.rawValue }) {
                                let category = MovieSourceCategory()
                                category.category = MovieSourceCategoryType.popular.rawValue
                                movieObject.categories.append(category)
                            }
                            return movieObject
                        }
                        
                        try environment.realm.save(objects)
                        return .run { send in
                            await send(.getPopularMoviesFromDatabase)
                        }
                    } catch {
                        return .none
                    }
                case let .failure(error):
                    print(error)
                    return .none
                }
                
            case .getPopularMoviesFromDatabase:
                return environment.realm
                    .fetch(MovieObject.self)
                    .map { results -> Dashboard.Action in
                        let movies = Array(results.filter { $0.categories.contains { category in
                            return category.category == MovieSourceCategoryType.popular.rawValue
                        }}.map { $0.movie })
                        return .updatePopularMovie(movies)
                    }
            case let .updatePopularMovie(movies):
                state.popularMovies = IdentifiedArrayOf(uniqueElements: movies)
                return .none
            case .loadTopRatedMovies:
                state.isLoading = true
                return .run { send in
                    await send(.topRatedMoviesResponse(.init {
                        try await self.movieClient.topRatedMovies()
                    }))
                }
                // MARK: Top Rated Movies
            case let .topRatedMoviesResponse(result):
                state.isLoading = false
                switch result {
                case let .success(dto):
                    do {
                        let objects = dto.results.map { $0.movieObject }.map { movieObject in
                            if !movieObject.categories.contains(where: { $0.category == MovieSourceCategoryType.topRated.rawValue }) {
                                let category = MovieSourceCategory()
                                category.category = MovieSourceCategoryType.topRated.rawValue
                                movieObject.categories.append(category)
                            }
                            return movieObject
                        }
                        try environment.realm.save(objects)
                        return .run { send in
                            await send(.getTopRatedMoviesFromDatabase)
                        }
                    } catch {
                        return .none
                    }
                case let .failure(error):
                    print(error)
                    return .none
                }
            case .getTopRatedMoviesFromDatabase:
                return environment.realm
                    .fetch(MovieObject.self)
                    .map { results -> Dashboard.Action in
                        let movies = Array(results.filter { return $0.categories.contains { category in
                            category.category == MovieSourceCategoryType.topRated.rawValue
                        }}.map { $0.movie })
                        return .updateTopRatedMovies(movies)
                    }
            case .updateTopRatedMovies(let movies):
                state.topRatedMovies = IdentifiedArrayOf(uniqueElements: movies)
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}
