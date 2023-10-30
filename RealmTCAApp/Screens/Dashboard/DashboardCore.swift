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
        
        var popularMoviesCarusel = MoviesCarusel.State(category: .popular)
        var topRatedMoviesCarusel = MoviesCarusel.State(category: .topRated)
        var nowPlayingMoviesCarusel = MoviesCarusel.State(category: .nowPlaying)
        var horrorMoviesCarusel = MoviesCarusel.State(category: .genre(GenreModel(id: 27, name: "Horor")))
        var loveMoviesCarusel = MoviesCarusel.State(category: .genre(GenreModel(id: 10749, name: "Liebensfilm")))
        var animationMoviesCarusel = MoviesCarusel.State(category: .genre(GenreModel(id: 16, name: "Animation")))
        var documentationMoviesCarusel = MoviesCarusel.State(category: .genre(GenreModel(id: 99, name: "Dokumentation")))
    }
    
    enum Action {
        
        case showError(AppError)
        case none
        
        case goToSeen
        case goToWatchlist
        case goToSearch
        case gotToMovie(MovieModel)
        case path(StackAction<Path.State, Path.Action>)
        
        case popularMoviesCarusel(MoviesCarusel.Action)
        case topRatedMoviesCarusel(MoviesCarusel.Action)
        case nowPlayingMoviesCarusel(MoviesCarusel.Action)
        case horrorMoviesCarusel(MoviesCarusel.Action)
        case loveMoviesCarusel(MoviesCarusel.Action)
        case animationMoviesCarusel(MoviesCarusel.Action)
        case documentationMoviesCarusel(MoviesCarusel.Action)
        
        case fetchGenreMovies
        case genreMoviesReponse(TaskResult<GenresDto>)
    }
    
    @Dependency(\.moviesClient) var movieClient
    
    var body: some Reducer<State, Action> {
        
        Scope(state: \.popularMoviesCarusel, action: /Action.popularMoviesCarusel) {
            MoviesCarusel()
        }
        
        Scope(state: \.topRatedMoviesCarusel, action: /Action.topRatedMoviesCarusel) {
            MoviesCarusel()
        }
        
        Scope(state: \.nowPlayingMoviesCarusel, action: /Action.nowPlayingMoviesCarusel) {
            MoviesCarusel()
        }
        
        Scope(state: \.horrorMoviesCarusel, action: /Action.horrorMoviesCarusel) {
            MoviesCarusel()
        }
        
        Scope(state: \.loveMoviesCarusel, action: /Action.loveMoviesCarusel) {
            MoviesCarusel()
        }
        
        Scope(state: \.animationMoviesCarusel, action: /Action.animationMoviesCarusel) {
            MoviesCarusel()
        }
        
        Scope(state: \.documentationMoviesCarusel, action: /Action.documentationMoviesCarusel) {
            MoviesCarusel()
        }
        
        Reduce { state, action in
            
            switch action {
            case let .popularMoviesCarusel(movieCaruselAction),
                let .topRatedMoviesCarusel(movieCaruselAction),
                let .nowPlayingMoviesCarusel(movieCaruselAction),
                let .horrorMoviesCarusel(movieCaruselAction),
                let .loveMoviesCarusel(movieCaruselAction),
                let .animationMoviesCarusel(movieCaruselAction),
                let .documentationMoviesCarusel(movieCaruselAction):
                switch movieCaruselAction {
                case let .gotToMovie(movieModel):
                    state.path.append(.movie(.init(movie: movieModel)))
                    return .none
                default:
                    return .none
                }
            case .goToSeen:
                state.path.append(.seen(.init()))
                return .none
            case .goToWatchlist:
                state.path.append(.watchlist(.init()))
                return .none
            case .goToSearch:
                state.path.append(.search(.init()))
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
                case let .element(id: _, action: .search(.detailMovieButtonTapped(movie))):
                    state.path.append(.movie(.init(movie: movie)))
                    return .none
                default:
                    return .none
                }
            case .showError(let appError):
                print(appError)
                return .none
            case .fetchGenreMovies:
                return .run { send in
                    await send(.genreMoviesReponse(.init {
                        try await self.movieClient.genreMovies()
                    }))
                }
            case let .genreMoviesReponse(.success(dto)):
                let objects = dto.genres
                    .map { $0.genre }
                return environment.realm.save(objects).map { signal in
                    switch signal {
                    case .success:
                        return .none
                    case let .failure(appError):
                        return .showError(appError)
                    }
                }
            case let .genreMoviesReponse(.failure(error)):
                return .run { send in
                    await send(.showError(AppError.other(error)))
                }
            case .none:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
    
}
