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
        
        var popularMoviesCarusel = MovieCarusel.State(category: .popular)
        var topRatedMoviesCarusel = MovieCarusel.State(category: .topRated)
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
        
        case popularMoviesCarusel(MovieCarusel.Action)
        case topRatedMoviesCarusel(MovieCarusel.Action)
    }
    
    @Dependency(\.moviesClient) var movieClient
    
    var body: some Reducer<State, Action> {
        
        Scope(state: \.popularMoviesCarusel, action: /Action.popularMoviesCarusel) {
            MovieCarusel()
        }
        
        Scope(state: \.topRatedMoviesCarusel, action: /Action.topRatedMoviesCarusel) {
            MovieCarusel()
        }
        
        Reduce { state, action in
            switch action {
            case let .popularMoviesCarusel(movieCaruselAction):
                switch movieCaruselAction {
                case let .gotToMovie(movieModel):
                    state.path.append(.movie(.init(movie: movieModel)))
                    return .none
                default:
                    return .none
                }
            case let .topRatedMoviesCarusel(movieCaruselAction):
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
                
            case .showError(let appError):
                print(appError)
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
    
}
