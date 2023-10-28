//
//  WatchedCore.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Foundation

import ComposableArchitecture
import RealmSwift

struct SeenEnvironment {
    
    let realm: Realm
    
    init() {
        
        self.realm = try! Realm()
    }
    
    init(realm: Realm) {
        
        self.realm = realm
    }
}

struct Seen: Reducer {
    
    let environment = SeenEnvironment()
    
    struct State: Equatable, Hashable, Codable {
    
        var movies: IdentifiedArrayOf<MovieModel> = []
        var additional: IdentifiedArrayOf<MovieAdditionalModel> = []
    }
    
    enum Action: Equatable, Sendable {
        
        case loadData
        case updateMovieAdditional([MovieAdditionalModel])
        case loadMovies
        case updateMovies([MovieModel])
        case path(StackAction<Movie.State, Movie.Action>)
        case detailMovieButtonTapped(MovieModel)
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .loadData:
                return environment.realm.fetch(MovieAdditionalObject.self)
                    .map { results -> Seen.Action in
                        let seenMoviesAdditional = Array(results.filter { $0.seen }.map { $0.movieAdditional })
                        return .updateMovieAdditional(seenMoviesAdditional)
                    }
            case let .updateMovieAdditional(additional):
                state.additional = IdentifiedArray(uniqueElements: additional)
                return .run { send in
                    await send(.loadMovies)
                }
            case .loadMovies:
                let seenIds = Set(state.additional.map { $0.id })
                return environment.realm.fetch(MovieObject.self)
                    .map { results -> Seen.Action in
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
            }
        }
    }
    
}
