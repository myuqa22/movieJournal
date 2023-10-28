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
        var movieRating: MovieRating.State?
        var isSheetPresented = false
    }
    
    enum Action: Equatable {
        
        case showError(AppError)
        
        case loadOrCreateAdditional
        case watchlistButtonTapped
        case seenButtonTapped
        case setupAdditional(MovieAdditionalModel)
        case createAdditional
        case customRatingButtonTapped
        
        case movieRating(MovieRating.Action)
        case setSheet(isPresented: Bool)
        case setSheetIsPresentedDelayCompleted
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case load }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .watchlistButtonTapped:
                state.movieAdditional?.bookmarked.toggle()
                if let movieAdditionalObject = state.movieAdditional?.movieAdditionalObject {
                    return environment.realm
                        .save(movieAdditionalObject)
                        .map { signal in
                            switch signal {
                            case .success:
                                return .loadOrCreateAdditional
                            case .failure(let appError):
                                return .showError(appError)
                            }
                        }
                }
                return .none
            case .seenButtonTapped:
                state.movieAdditional?.seen.toggle()
                if let movieAdditionalObject = state.movieAdditional?.movieAdditionalObject {
                    return environment.realm
                        .save(movieAdditionalObject)
                        .map { signal in
                            switch signal {
                            case .success:
                                return .loadOrCreateAdditional
                            case .failure(let appError):
                                return .showError(appError)
                            }
                        }
                } else {
                    return .run { send in
                        await send(.showError(AppError.missingData))
                    }
                }
            case .loadOrCreateAdditional:
                return environment.realm
                    .fetch(
                        MovieAdditionalObject.self,
                        predicate: NSPredicate(format: "id == %d", state.movie.id as CVarArg))
                    .map { objects -> Movie.Action in
                        if let movieAdditional = objects.first?.movieAdditional {
                            return .setupAdditional(movieAdditional)
                        } else {
                            return .createAdditional
                        }
                    }
            case .createAdditional:
                let additional = MovieAdditionalObject()
                additional.id = state.movie.id
                additional.customDescription = String()
                additional.bookmarked = false
                additional.seen = false
                additional.customRating = 0
                return environment.realm
                    .create(MovieAdditionalObject.self, object: additional)
                    .map { signal -> Movie.Action in
                        switch signal {
                        case .success:
                            return .setupAdditional(additional.movieAdditional)
                        case .failure(let appError):
                            return .showError(appError)
                        }
                    }
            case let .setupAdditional(model):
                state.movieAdditional = model
                return .none
            case .customRatingButtonTapped:
                
                return .none
            case let .showError(appError):
                print(appError)
                return .none
            case let .movieRating(movieRatingAction):
                switch movieRatingAction {
                case let .saveCustomRating(rating):
                    let additional = state.movieAdditional?.movieAdditionalObject
                    additional?.customRating = rating
                    if let additional {
                        return environment.realm.save(additional).map { signal in
                            switch signal {
                            case .success:
                                return .setupAdditional(additional.movieAdditional)
                            case .failure(let appError):
                                return .showError(appError)
                            }
                        }
                    }
                    return .none
                default:
                    return .none
                }
            case .setSheet(isPresented: true):
                state.isSheetPresented = true
                return .run { send in
                  try await self.clock.sleep(for: .seconds(1))
                  await send(.setSheetIsPresentedDelayCompleted)
                }
                .cancellable(id: CancelID.load)
            case .setSheet(isPresented: false):
                state.isSheetPresented = false
                state.movieRating = nil
                return .cancel(id: CancelID.load)
            case .setSheetIsPresentedDelayCompleted:
                state.movieRating = MovieRating.State(progress: state.movieAdditional?.customRating ?? .zero)
                return .none
            }
        }
        .ifLet(\.movieRating, action: /Action.movieRating) {
          MovieRating()
        }
    }
    
}
