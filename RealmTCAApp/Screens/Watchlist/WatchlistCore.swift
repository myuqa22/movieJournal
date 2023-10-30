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

        var sortBy: SortType = .alphabeticallyAscending
        var additional: IdentifiedArrayOf<MovieWrapperModel> = []
        var sortedAdditional: IdentifiedArrayOf<MovieWrapperModel> = []
        var genres: IdentifiedArrayOf<GenreModel> = []
    }
    
    enum Action: Equatable, Sendable {
        
        case loadBookmarkedAdditional
        case updateAdditional([MovieWrapperModel])
        case loadMovies
        case updateMovies([MovieModel])
        case path(StackAction<Movie.State, Movie.Action>)
        case detailMovieButtonTapped(MovieModel)
        case loadGenres
        case updateGenres([GenreModel])
        case sortMovies(SortType? = nil)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .loadBookmarkedAdditional:
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
                            .filter { seenIds.contains($0.id )}
                            .map { $0.movie })
                        return .updateMovies(movies)
                    }
            case var .updateMovies(movies):
                var removeMissingMovieIds = Set<Int>()
                for index in state.additional.indices {
                    if let movieIndex = movies.firstIndex(where: { $0.id == state.additional[index].id }) {
                        state.additional[index].movie = movies.remove(at: movieIndex)
                    } else {
                        removeMissingMovieIds.insert(index)
                    }
                }
                
                state.additional.removeAll(where: { removeMissingMovieIds.contains($0.id)})
                return .run { send in
                    await send(.sortMovies())
                }
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
            case let .sortMovies(filterType):
                state.sortBy = filterType ?? .alphabeticallyAscending
                switch state.sortBy {
                case .alphabeticallyAscending:
                    state.sortedAdditional = IdentifiedArray(
                        uniqueElements: state.additional
                            .filter { $0.movie != nil }
                            .sorted { $0.movie!.title < $1.movie!.title }
                    )
                case .alphabeticallyDecending:
                    state.sortedAdditional = IdentifiedArray(
                        uniqueElements: state.additional
                            .filter { $0.movie != nil }
                            .sorted { $0.movie!.title > $1.movie!.title }
                    )
                case .ratingAscending:
                    state.sortedAdditional = IdentifiedArray(
                        uniqueElements: state.additional
                            .filter { $0.movie != nil }
                            .sorted { $0.movie!.rating < $1.movie!.rating }
                    )
                case .ratingDecending:
                    state.sortedAdditional = IdentifiedArray(
                        uniqueElements: state.additional
                            .filter { $0.movie != nil }
                            .sorted { $0.movie!.rating > $1.movie!.rating }
                    )
                case .customRatingAscendig:
                    state.sortedAdditional = IdentifiedArray(
                        uniqueElements: state.additional
                            .filter { $0.movie != nil }
                            .sorted { $0.customRating < $1.customRating }
                    )
                case .customRatingDecending:
                    state.sortedAdditional = IdentifiedArray(
                        uniqueElements: state.additional
                            .filter { $0.movie != nil }
                            .sorted { $0.customRating > $1.customRating }
                    )
                case .releaseAscending:
                    state.sortedAdditional = IdentifiedArray(
                        uniqueElements: state.additional
                            .filter { $0.movie?.releaseDate != nil}
                            .sorted { $0.movie!.releaseDate! < $1.movie!.releaseDate! }
                    )
                case .releaseDecending:
                    state.sortedAdditional = IdentifiedArray(
                        uniqueElements: state.additional
                            .filter { $0.movie?.releaseDate != nil}
                            .sorted { $0.movie!.releaseDate! > $1.movie!.releaseDate! }
                    )
                }
                return .none
            }
        }
    }
    
}
