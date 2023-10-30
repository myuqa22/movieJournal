//
//  SearchCore.swift
//  RealmTCAApp
//
//  Created by Privat on 28.10.23.
//

import Foundation

import ComposableArchitecture
import RealmSwift

struct SearchEnvironment {
    
    let realm: Realm
    
    init() {
        
        self.realm = try! Realm()
    }
    
    init(realm: Realm) {
        
        self.realm = realm
    }
    
}

struct Search: Reducer {
    
    let environment = SearchEnvironment()

    struct State: Equatable, Codable, Hashable {
    
        @BindingState var searchInput: String = String()
        var searchResults = IdentifiedArrayOf<MovieModel>()
    }
    
    enum Action: BindableAction {
        
        case binding(BindingAction<State>)
        case updateSearchQuery(String)
        
        case searchMovies
        case searchMoviesResponse(TaskResult<MoviesDto>)
        case updateSearchMovies([MovieModel])
        
        case detailMovieButtonTapped(MovieModel)
    }
    
    @Dependency(\.moviesClient) var movieClient
    
    var body: some Reducer<State, Action> {
        
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .searchMovies:
                return .run { [state = state] send in
                    await send(.searchMoviesResponse(.init {
                        try await self.movieClient.searchMovies(state.searchInput)
                    }))
                }
            case let .updateSearchQuery(keyword):
                state.searchInput = keyword
                return .none
            case let .searchMoviesResponse(.success(dto)):
                return .run { send in
                    await send(.updateSearchMovies(Array(dto.results.map { $0.movieModel })))
                }
            case let .searchMoviesResponse(.failure(error)):
                print(error)
                return .none
            case let .updateSearchMovies(searchResults):
                state.searchResults = IdentifiedArray(uniqueElements: searchResults)
                return .none
            case .detailMovieButtonTapped:
                return .none
            }
        }
    }
}
