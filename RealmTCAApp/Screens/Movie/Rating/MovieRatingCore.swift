//
//  MovieRatingCore.swift
//  RealmTCAApp
//
//  Created by Privat on 27.10.23.
//

import Foundation

import ComposableArchitecture
import RealmSwift

struct MovieRatingEnvironment {
    
    let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    init(realm: Realm) {
        self.realm = realm
    }
}

struct MovieRating: Reducer {
    
    let environment = MovieRatingEnvironment()
    
    struct State: Equatable, Codable, Hashable {
        @BindingState var progress: Double
        @BindingState var stepCount: Double = Constants.maxRating
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case changeProgress(Double)
        case saveCustomRating(Double)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
              return .none
            case let .changeProgress(newProgress):
                state.progress = .minimum(newProgress, state.stepCount)
                return .none
            case .saveCustomRating:
                return .none
            }
        }
    }
}
