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
        
        case showError(AppError)
        
        case goToSeen
        case goToWatchlist
        case gotToMovie(MovieModel)
        case path(StackAction<Path.State, Path.Action>)
        
        // MARK: Popular Movies
        case fetchPopularMovies
        case popularMoviesResponse(TaskResult<PopularMoviesDto>)
        case getPopularMoviesFromDatabase
        case updatePopularMovie([MovieModel])
        
        // MARK: Top Rated Movies
        case fetchTopRatedMovies
        case topRatedMoviesResponse(TaskResult<TopRatedMoviesDto>)
        case getTopRatedMoviesFromDatabase
        case updateTopRatedMovies([MovieModel])
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
                // MARK: Popular movies
            case .fetchPopularMovies:
                state.isLoading = true
                return .run { send in
                    await send(.popularMoviesResponse(.init {
                        try await self.movieClient.popularMovies()
                    }))
                }
            case let .popularMoviesResponse(result):
                state.isLoading = false
                return handlePopularMovieResponse(result: result)
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
            case .fetchTopRatedMovies:
                state.isLoading = true
                return .run { send in
                    await send(.topRatedMoviesResponse(.init {
                        try await self.movieClient.topRatedMovies()
                    }))
                }
                // MARK: Top Rated Movies
            case let .topRatedMoviesResponse(result):
                return handleTopRatedMoviesResponse(result: result)
            case .getTopRatedMoviesFromDatabase:
                return handleGetTopRatedMoviesFromDatabase()
            case .updateTopRatedMovies(let movies):
                state.topRatedMovies = IdentifiedArrayOf(uniqueElements: movies)
                return .none
                
            case .showError(let appError):
                print(appError)
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
    
    
    private func handlePopularMovieResponse(result: TaskResult<PopularMoviesDto>) -> Effect<Dashboard.Action> {
        switch result {
        case let .success(dto):
            let objects = dto.results.map { $0.movieObject }.map { movieObject in
                if !movieObject.categories.contains(
                    where: { $0.category == MovieSourceCategoryType.popular.rawValue }) {
                    let category = MovieSourceCategory()
                    category.category = MovieSourceCategoryType.popular.rawValue
                    movieObject.categories.append(category)
                }
                return movieObject
            }
            
            return environment.realm.save(objects).map { signal -> Dashboard.Action in
                switch signal {
                case .success:
                    return .getPopularMoviesFromDatabase
                case .failure(let appError):
                    return .showError(appError)
                }
            }
            
        case let .failure(error):
            print(error)
            return .none
        }
    }
    
    private func handleGetTopRatedMoviesFromDatabase() -> Effect<Dashboard.Action> {
        
        environment.realm
            .fetch(MovieObject.self)
            .map { results -> Dashboard.Action in
                let movies = Array(results.filter { return $0.categories.contains { category in
                    category.category == MovieSourceCategoryType.topRated.rawValue
                }}.map { $0.movie })
                return .updateTopRatedMovies(movies)
            }
    }
    
    private func handleTopRatedMoviesResponse(result: TaskResult<TopRatedMoviesDto>) -> Effect<Dashboard.Action> {
        
        switch result {
        case let .success(dto):
            let objects = dto.results.map { $0.movieObject }.map { movieObject in
                // add category
                if !movieObject.categories.contains(where: { $0.category == MovieSourceCategoryType.topRated.rawValue }) {
                    let category = MovieSourceCategory()
                    category.category = MovieSourceCategoryType.topRated.rawValue
                    movieObject.categories.append(category)
                }
                return movieObject
            }
            return environment.realm
                .save(objects)
                .map { signal -> Dashboard.Action in
                    switch signal {
                    case .success:
                        return .getTopRatedMoviesFromDatabase
                    case .failure(let appError):
                        return .showError(appError)
                        
                    }
                }
        case let .failure(error):
            print(error)
            return .none
        }
    }
    
}
