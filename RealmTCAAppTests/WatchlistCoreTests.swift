//
//  WatchlistCoreTests.swift
//  RealmTCAAppTests
//
//  Created by Privat on 27.10.23.
//

import XCTest

import ComposableArchitecture
import RealmSwift

@testable import RealmTCAApp

@MainActor
final class WatchlistCoreTests: XCTestCase {

    override class func setUp() {
        
        super.setUp()
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = String(describing: self)
    }

    func testSuccessfullyLoadMovie() async throws {
       
        let realm = try await Realm()
        
        let id = 1
        let additionalMovieObject = MovieAdditionalObject()
        additionalMovieObject.id = id
        additionalMovieObject.customDescription = "customDescription"
        additionalMovieObject.customRating = 5
        additionalMovieObject.bookmarked = true
        additionalMovieObject.seen = false
        
        let movieObject = MovieObject()
        movieObject.id = id
        movieObject.title = "title"
        
        try! realm.write {
            realm.add(additionalMovieObject)
            realm.add(movieObject)
        }
        
        let store = TestStore(initialState: Watchlist.State()) {
            Watchlist()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadAdditional)
        await store.receive(.updateAdditional([additionalMovieObject.movieAdditional]), timeout: 1) { state in
            state.additional = [additionalMovieObject.movieAdditional]
        }
        await store.receive(.loadMovies, timeout: 1)
        
        var movieWrapper = additionalMovieObject.movieAdditional
        movieWrapper.movie = movieObject.movie
        
        await store.receive(.updateMovies([movieObject.movie]), timeout: 1) { state in
            state.additional = [movieWrapper]
        }
        await store.receive(.sortMovies(nil), timeout: 1) { state in
            state.sortedAdditional = [
                movieWrapper
            ]
        }
    }
    
    func testNoWatchlistMovies() async throws {
       
        let realm = try await Realm()
        
        let id = 1
        let additionalMovieObject = MovieAdditionalObject()
        additionalMovieObject.id = id
        additionalMovieObject.customDescription = "customDescription"
        additionalMovieObject.customRating = 5
        additionalMovieObject.bookmarked = false
        additionalMovieObject.seen = false
        
        let movieObject = MovieObject()
        movieObject.id = id
        movieObject.title = "title"
        
        try! realm.write {
            realm.add(additionalMovieObject)
            realm.add(movieObject)
        }
        
        let store = TestStore(initialState: Watchlist.State()) {
            Watchlist()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadAdditional)
        await store.receive(.updateAdditional([]), timeout: 1)
        await store.receive(.loadMovies, timeout: 1)
        await store.receive(.updateMovies([]), timeout: 1)
        await store.receive(.sortMovies(nil), timeout: 1)
    }

}
