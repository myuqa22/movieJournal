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
        var additionals = Set<MovieWrapperModel>()
        var mappedSearchResults = IdentifiedArrayOf<MovieWrapperModel>()
    }
    
    enum Action: BindableAction {
        
        case none
        
        case binding(BindingAction<State>)
        case updateSearchQuery(String)
        
        case searchMovies
        case searchMoviesResponse(TaskResult<MoviesDto>)
        case updateSearchMovies([MovieModel])
        
        case detailMovieButtonTapped(MovieModel)
        
        case loadAdditional
        case updateAdditional([MovieWrapperModel])
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
                state.mappedSearchResults.removeAll()
                for movie in searchResults {
                    if var wrapper = state.additionals.first(where: { $0.id == movie.id }) {
                        wrapper.movie = movie
                        state.mappedSearchResults.append(wrapper)
                    } else {
                        let wrapper = MovieWrapperModel(id: movie.id,
                                                        bookmarked: false,
                                                        seen: false,
                                                        customDescription: String(),
                                                        customRating: .zero, movie: movie)
                        state.mappedSearchResults.append(wrapper)
                    }
                }
                return .none
            case let .detailMovieButtonTapped(movieModel):
                return environment.realm.save(movieModel.movieObject).map { signal in
                    switch signal {
                    case .success:
                        return .none
                    case let .failure(appError):
                        print(appError)
                        return .none
                    }
                }
            case .loadAdditional:
                return environment.realm.fetch(MovieAdditionalObject.self)
                    .map { results in
                        return .updateAdditional(results.map({ $0.movieAdditional }))
                    }
            case let .updateAdditional(movieAdditional):
                state.additionals = Set(movieAdditional)
                return .none
            case .none:
                return .none
            }
        }
    }
    
}
