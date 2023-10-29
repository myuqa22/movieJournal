//
//  WatchlistCore.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import Foundation

import ComposableArchitecture
import RealmSwift

struct WatchlistEnvironment {
    
    let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    init(realm: Realm) {
        self.realm = realm
    }
}

struct Watchlist: Reducer {
    
    let environment = WatchlistEnvironment()
    
    struct State: Equatable, Hashable, Codable {
    
        var movies: IdentifiedArrayOf<MovieModel> = []
        var additional: IdentifiedArrayOf<MovieAdditionalModel> = []
        var genres: IdentifiedArrayOf<GenreModel> = []
    }
    
    enum Action: Equatable, Sendable {
        
        case loadAdditional
        case updateAdditional([MovieAdditionalModel])
        case loadMovies
        case updateMovies([MovieModel])
        case path(StackAction<Movie.State, Movie.Action>)
        case detailMovieButtonTapped(MovieModel)
        
        case loadGenres
        case updateGenres([GenreModel])
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .loadAdditional:
                return environment.realm.fetch(MovieAdditionalObject.self)
                    .map { results -> Watchlist.Action in
                        let seenMoviesAdditional = Array(results.filter { $0.bookmarked }.map { $0.movieAdditional })
                        return .updateAdditional(seenMoviesAdditional)
                    }
            case let .updateAdditional(moviesAdditional):
                state.additional = IdentifiedArray(uniqueElements: moviesAdditional)
                return .run { send in
                    await send(.loadMovies)
                }
            case .loadMovies:
                let seenIds = Set(state.additional.map { $0.id })
                return environment.realm.fetch(MovieObject.self)
                    .map { results -> Watchlist.Action in
                        let movies = Array(results
                            .filter{ seenIds.contains($0.id )}
                            .map { $0.movie })
                        return .updateMovies(movies)
                    }
            case let .updateMovies(movies):
                state.movies = IdentifiedArray(uniqueElements: movies)
                return .none
            case .path:
                return .none
            case .detailMovieButtonTapped:
                return .none
            case .loadGenres:
                return environment.realm
                    .fetch(GenreObject.self)
                    .map { results in
                        let genres = Array(results.map { $0.genre } )
                        return .updateGenres(genres)
                    }
            case let .updateGenres(genres):
                state.genres = IdentifiedArray(uniqueElements: genres)
                return .none
            }
        }
    }
}
