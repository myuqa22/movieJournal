//
//  SearchCoreTests.swift
//  RealmTCAAppTests
//
//  Created by Privat on 30.10.23.
//

import XCTest

import ComposableArchitecture
import RealmSwift

@testable import RealmTCAApp

@MainActor
final class SearchCoreTests: XCTestCase {

    override func setUp() {
        
        super.setUp()
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = String(describing: self)
    }
    
    func testOneSearchResults() async {
        
        let store = TestStore(initialState: Search.State()) {
            Search()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        let movie1 = MovieModel(id: 1, title: "title", 
                                image: nil,
                                rating: 1,
                                overview: "overview",
                                release_date: "2022-05-01",
                                genre_ids: [])
        
        let mappedMovie1 = MovieWrapperModel(id: 1,
                                             bookmarked: false,
                                             seen: false,
                                             customDescription: "",
                                             customRating: .zero,
                                             movie: movie1)
        let movieModels: [MovieModel] = [
            movie1
        ]
        
        await store.send(.updateSearchMovies(movieModels)) { state in
            state.searchResults = [movie1]
            state.mappedSearchResults = [mappedMovie1]
        }
    }
    
    func testThreeSearchHasAdditionalResults() async {
        
        let store = TestStore(initialState: Search.State()) {
            Search()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        let movie1 = MovieModel(id: 1, title: "title",
                                image: nil,
                                rating: 1,
                                overview: "overview",
                                release_date: "2022-05-01",
                                genre_ids: [])
        let mappedMovie1 = MovieWrapperModel(id: 1,
                                             bookmarked: false,
                                             seen: false,
                                             customDescription: "",
                                             customRating: .zero,
                                             movie: movie1)
        let movie2 = MovieModel(id: 2, title: "title",
                                image: nil,
                                rating: 2,
                                overview: "overview",
                                release_date: "2022-05-01",
                                genre_ids: [])
        let mappedMovie2 = MovieWrapperModel(id: 2,
                                             bookmarked: false,
                                             seen: false,
                                             customDescription: "",
                                             customRating: .zero,
                                             movie: movie2)
        
        let movie3 = MovieModel(id: 3, title: "title",
                                image: nil,
                                rating: 2,
                                overview: "overview",
                                release_date: "2022-05-01",
                                genre_ids: [])
        let mappedMovie3 = MovieWrapperModel(id: 3,
                                             bookmarked: false,
                                             seen: false,
                                             customDescription: "",
                                             customRating: .zero,
                                             movie: movie3)
        let movieModels: [MovieModel] = [
            movie1,
            movie2,
            movie3
        ]
        
        await store.send(.updateSearchMovies(movieModels)) { state in
            state.searchResults = [movie1, movie2, movie3]
            state.mappedSearchResults = [mappedMovie1, mappedMovie2, mappedMovie3]
        }
    }

    func testThreeSearchHasAdditionalInDatabaseResults() async {
        
        let realm = try! await Realm()
        
        let store = TestStore(initialState: Search.State()) {
            Search()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        let movie1 = MovieModel(id: 1, title: "title",
                                image: nil,
                                rating: 1,
                                overview: "overview",
                                release_date: "2022-05-01",
                                genre_ids: [])
        var mappedMovie1 = MovieWrapperModel(id: 1,
                                             bookmarked: true,
                                             seen: true,
                                             customDescription: "",
                                             customRating: 1,
                                             movie: nil)
        let movie2 = MovieModel(id: 2, title: "title",
                                image: nil,
                                rating: 2,
                                overview: "overview",
                                release_date: "2022-05-01",
                                genre_ids: [])
        var mappedMovie2 = MovieWrapperModel(id: 2,
                                             bookmarked: true,
                                             seen: true,
                                             customDescription: "",
                                             customRating: 2,
                                             movie: nil)
        
        let movie3 = MovieModel(id: 3, title: "title",
                                image: nil,
                                rating: 2,
                                overview: "overview",
                                release_date: "2022-05-01",
                                genre_ids: [])
        var mappedMovie3 = MovieWrapperModel(id: 3,
                                             bookmarked: true,
                                             seen: true,
                                             customDescription: "",
                                             customRating: 3,
                                             movie: nil)
        
        try! realm.write {
            realm.add(mappedMovie1.movieAdditionalObject)
            realm.add(mappedMovie2.movieAdditionalObject)
            realm.add(mappedMovie3.movieAdditionalObject)
        }
        
        let movieModels: [MovieModel] = [
            movie1,
            movie2,
            movie3
        ]
        
        await store.send(.loadAdditional)
        let mappedMovies = [mappedMovie1, mappedMovie2, mappedMovie3]
        await store.receive(/Search.Action.updateAdditional(mappedMovies), timeout: 1) { state in
            state.additionals = Set(mappedMovies)
        }
        
        mappedMovie1.movie = movie1
        mappedMovie2.movie = movie2
        mappedMovie3.movie = movie3
        
        await store.send(.updateSearchMovies(movieModels)) { state in
            state.searchResults = [movie1, movie2, movie3]
            state.mappedSearchResults = [mappedMovie1, mappedMovie2, mappedMovie3]
        }
    }
}
