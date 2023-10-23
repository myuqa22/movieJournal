//
//  MovieCore.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import Foundation

import ComposableArchitecture
import RealmSwift

struct MovieEnvironment {
    
    let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    init(realm: Realm) {
        self.realm = realm
    }
}

struct Movie: Reducer {
    
    let environment = MovieEnvironment()
    
    struct State: Equatable, Hashable, Codable {
        
        var movie: MovieModel
        var movieAdditional: MovieAdditionalModel?
    }
    
    enum Action: Equatable {
        case load
        case watchlistButtonTapped
        case seenButtonTapped
        case setupAdditional(MovieAdditionalModel)
        case createAdditional
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .watchlistButtonTapped:
                state.movieAdditional?.bookmarked.toggle()
                if let movieAdditionalObject = state.movieAdditional?.movieAdditionalObject {
                    _ = environment.realm.save(movieAdditionalObject)
                }
                return .none
            case .seenButtonTapped:
                state.movieAdditional?.seen.toggle()
                if let movieAdditionalObject = state.movieAdditional?.movieAdditionalObject {
                    _ = environment.realm.save(movieAdditionalObject)
                }
                return .none
            case .load:
                return environment.realm
                    .fetch(
                        MovieAdditionalObject.self,
                        predicate: NSPredicate(format: "id == %@", state.movie.id as CVarArg))
                    .map { objects -> Movie.Action in
                        if let movieAdditional = objects.first?.movieAdditional {
                            return .setupAdditional(movieAdditional)
                        } else {
                            return .createAdditional
                        }
                        
                    }
            case let .setupAdditional(model):
                state.movieAdditional = model
                return .none
            case .createAdditional:
                let additional = MovieAdditionalObject()
                additional.id = state.movie.id
                additional.customDescription = String()
                additional.favorite = false
                additional.seen = false
                additional.customRating = 0
                return environment.realm.create(MovieAdditionalObject.self, object: additional)
                    .map { object -> Movie.Action in
                        return .setupAdditional(object.movieAdditional)
                    }
            }
        }
    }
}
