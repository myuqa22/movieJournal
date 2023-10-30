//
//  SeenCoreTests.swift
//  RealmTCAAppTests
//
//  Created by Privat on 27.10.23.
//

import XCTest

import ComposableArchitecture
import RealmSwift

@testable import RealmTCAApp

@MainActor
final class SeenCoreTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = String(describing: self)
    }
    
    func testSuccessfullyLoadMovie() async {
        
        let realm = try! await Realm()
        let id = 1
        
        let additionalMovieObject = MovieAdditionalObject()
        additionalMovieObject.id = id
        additionalMovieObject.customDescription = "customDescription"
        additionalMovieObject.customRating = 5
        additionalMovieObject.bookmarked = true
        additionalMovieObject.seen = true
        
        let movieObject = MovieObject()
        movieObject.id = id
        movieObject.title = "title"
        
        try! realm.write {
            realm.add(additionalMovieObject)
            realm.add(movieObject)
        }
        
        let store = TestStore(initialState: Seen.State()) {
            Seen()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadData)
        await store.receive(.updateMovieAdditional([additionalMovieObject.movieAdditional]), timeout: 1) { state in
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
    
    func testNoSeenMovies() async {
        
        let realm = try! await Realm()
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
        
        let store = TestStore(initialState: Seen.State()) {
            Seen()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadData)
        await store.receive(.updateMovieAdditional([]), timeout: 1)
        await store.receive(.loadMovies, timeout: 1)
        await store.receive(.updateMovies([]), timeout: 1)
        await store.receive(.sortMovies(nil), timeout: 1)
    }
    
    func testSeenMoviesMissingMovieModel() async {
        
        let realm = try! await Realm()
        let id = 1
        
        let additionalMovieObject = MovieAdditionalObject()
        additionalMovieObject.id = id
        additionalMovieObject.customDescription = "customDescription"
        additionalMovieObject.customRating = 5
        additionalMovieObject.bookmarked = false
        additionalMovieObject.seen = true
        
        try! realm.write {
            realm.add(additionalMovieObject)
        }
        
        let store = TestStore(initialState: Seen.State()) {
            Seen()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadData)
        await store.receive(.updateMovieAdditional([additionalMovieObject.movieAdditional]), timeout: 1) { state in
            state.additional = [additionalMovieObject.movieAdditional]
        }
        await store.receive(.loadMovies, timeout: 1)
        await store.receive(.updateMovies([]), timeout: 1)
        await store.receive(.sortMovies(nil), timeout: 1)
    }
    
    func testSortByAlphabet() async {
        
        let realm = try! await Realm()
        
        let idA = 1
        let additionalA = MovieAdditionalObject()
        additionalA.id = idA
        additionalA.customDescription = "customDescription"
        additionalA.customRating = 1
        additionalA.bookmarked = false
        additionalA.seen = true
        let movieA = MovieObject()
        movieA.id = idA
        movieA.title = "A"
        movieA.release = "2020-03-01"
        
        let idB = 2
        let additionalB = MovieAdditionalObject()
        additionalB.id = idB
        additionalB.customDescription = "customDescription"
        additionalB.customRating = 2
        additionalB.bookmarked = false
        additionalB.seen = true
        let movieB = MovieObject()
        movieB.id = idB
        movieB.title = "B"
        movieB.rating = 2
        movieB.release = "2020-03-02"
        
        let idC = 3
        let additionalC = MovieAdditionalObject()
        additionalC.id = idC
        additionalC.customDescription = "customDescription"
        additionalC.customRating = 3
        additionalC.bookmarked = false
        additionalC.seen = true
        let movieC = MovieObject()
        movieC.id = idC
        movieC.title = "C"
        movieC.rating = 3
        movieB.release = "2020-03-03"
        
        let idD = 4
        let additionalD = MovieAdditionalObject()
        additionalD.id = idD
        additionalD.customDescription = "customDescription"
        additionalD.customRating = 4
        additionalD.bookmarked = false
        additionalD.seen = false
        let movieD = MovieObject()
        movieD.id = idD
        movieD.title = "C"
        movieD.rating = 4
        movieB.release = "2020-03-04"
        
        
        try! realm.write {
            realm.add(additionalA)
            realm.add(movieA)
            
            realm.add(additionalB)
            realm.add(movieB)
            
            realm.add(additionalC)
            realm.add(movieC)
            
            realm.add(additionalD)
            realm.add(movieD)
        }
        
        let store = TestStore(initialState: Seen.State()) {
            Seen()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadData)
        let movieAdditionalFromDatabase: IdentifiedArrayOf = [
            additionalA.movieAdditional,
            additionalB.movieAdditional,
            additionalC.movieAdditional
        ]
        await store.receive(.updateMovieAdditional(Array(movieAdditionalFromDatabase)), timeout: 1) { state in
            state.additional = movieAdditionalFromDatabase
        }
        await store.receive(.loadMovies, timeout: 1)
        
        let moviesFromDatabase = [
            movieA.movie,
            movieB.movie,
            movieC.movie,
        ]
        
        var movieAWrapper = additionalA.movieAdditional
        movieAWrapper.movie = movieA.movie
        
        var movieBWrapper = additionalB.movieAdditional
        movieBWrapper.movie = movieB.movie
        
        var movieCWrapper = additionalC.movieAdditional
        movieCWrapper.movie = movieC.movie
        
        await store.receive(.updateMovies(moviesFromDatabase), timeout: 1) { state in
            state.additional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.receive(.sortMovies(nil), timeout: 1) { state in
            state.sortBy = .alphabeticallyAscending
            state.sortedAdditional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.send(.sortMovies(.alphabeticallyDecending)) { state in
            state.sortBy = .alphabeticallyDecending
            state.sortedAdditional = [
                movieCWrapper,
                movieBWrapper,
                movieAWrapper
            ]
        }
    }

    func testSortByCustomRating() async {
        
        let realm = try! await Realm()
        
        let idA = 1
        let additionalA = MovieAdditionalObject()
        additionalA.id = idA
        additionalA.customDescription = "customDescription"
        additionalA.customRating = 1
        additionalA.bookmarked = false
        additionalA.seen = true
        let movieA = MovieObject()
        movieA.id = idA
        movieA.title = "A"
        movieA.release = "2020-03-01"
        
        let idB = 2
        let additionalB = MovieAdditionalObject()
        additionalB.id = idB
        additionalB.customDescription = "customDescription"
        additionalB.customRating = 2
        additionalB.bookmarked = false
        additionalB.seen = true
        let movieB = MovieObject()
        movieB.id = idB
        movieB.title = "B"
        movieB.rating = 2
        movieB.release = "2020-03-02"
        
        let idC = 3
        let additionalC = MovieAdditionalObject()
        additionalC.id = idC
        additionalC.customDescription = "customDescription"
        additionalC.customRating = 3
        additionalC.bookmarked = false
        additionalC.seen = true
        let movieC = MovieObject()
        movieC.id = idC
        movieC.title = "C"
        movieC.rating = 3
        movieB.release = "2020-03-03"
        
        let idD = 4
        let additionalD = MovieAdditionalObject()
        additionalD.id = idD
        additionalD.customDescription = "customDescription"
        additionalD.customRating = 4
        additionalD.bookmarked = false
        additionalD.seen = false
        let movieD = MovieObject()
        movieD.id = idD
        movieD.title = "C"
        movieD.rating = 4
        movieB.release = "2020-03-04"
        
        
        try! realm.write {
            realm.add(additionalA)
            realm.add(movieA)
            
            realm.add(additionalB)
            realm.add(movieB)
            
            realm.add(additionalC)
            realm.add(movieC)
            
            realm.add(additionalD)
            realm.add(movieD)
        }
        
        let store = TestStore(initialState: Seen.State()) {
            Seen()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadData)
        let movieAdditionalFromDatabase: IdentifiedArrayOf = [
            additionalA.movieAdditional,
            additionalB.movieAdditional,
            additionalC.movieAdditional
        ]
        await store.receive(.updateMovieAdditional(Array(movieAdditionalFromDatabase)), timeout: 1) { state in
            state.additional = movieAdditionalFromDatabase
        }
        await store.receive(.loadMovies, timeout: 1)
        
        let moviesFromDatabase = [
            movieA.movie,
            movieB.movie,
            movieC.movie,
        ]
        
        var movieAWrapper = additionalA.movieAdditional
        movieAWrapper.movie = movieA.movie
        
        var movieBWrapper = additionalB.movieAdditional
        movieBWrapper.movie = movieB.movie
        
        var movieCWrapper = additionalC.movieAdditional
        movieCWrapper.movie = movieC.movie
        
        await store.receive(.updateMovies(moviesFromDatabase), timeout: 1) { state in
            state.additional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.receive(.sortMovies(nil), timeout: 1) { state in
            state.sortBy = .alphabeticallyAscending
            state.sortedAdditional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.send(.sortMovies(.customRatingAscendig)) { state in
            state.sortBy = .customRatingAscendig
            state.sortedAdditional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.send(.sortMovies(.customRatingDecending)) { state in
            state.sortBy = .customRatingDecending
            state.sortedAdditional = [
                movieCWrapper,
                movieBWrapper,
                movieAWrapper
            ]
        }
    }

    func testSortByRating() async {
        
        let realm = try! await Realm()
        
        let idA = 1
        let additionalA = MovieAdditionalObject()
        additionalA.id = idA
        additionalA.customDescription = "customDescription"
        additionalA.customRating = 1
        additionalA.bookmarked = false
        additionalA.seen = true
        let movieA = MovieObject()
        movieA.id = idA
        movieA.title = "A"
        movieA.release = "2020-03-01"
        
        let idB = 2
        let additionalB = MovieAdditionalObject()
        additionalB.id = idB
        additionalB.customDescription = "customDescription"
        additionalB.customRating = 2
        additionalB.bookmarked = false
        additionalB.seen = true
        let movieB = MovieObject()
        movieB.id = idB
        movieB.title = "B"
        movieB.rating = 2
        movieB.release = "2020-03-02"
        
        let idC = 3
        let additionalC = MovieAdditionalObject()
        additionalC.id = idC
        additionalC.customDescription = "customDescription"
        additionalC.customRating = 3
        additionalC.bookmarked = false
        additionalC.seen = true
        let movieC = MovieObject()
        movieC.id = idC
        movieC.title = "C"
        movieC.rating = 3
        movieB.release = "2020-03-03"
        
        let idD = 4
        let additionalD = MovieAdditionalObject()
        additionalD.id = idD
        additionalD.customDescription = "customDescription"
        additionalD.customRating = 4
        additionalD.bookmarked = false
        additionalD.seen = false
        let movieD = MovieObject()
        movieD.id = idD
        movieD.title = "C"
        movieD.rating = 4
        movieB.release = "2020-03-04"
        
        
        try! realm.write {
            realm.add(additionalA)
            realm.add(movieA)
            
            realm.add(additionalB)
            realm.add(movieB)
            
            realm.add(additionalC)
            realm.add(movieC)
            
            realm.add(additionalD)
            realm.add(movieD)
        }
        
        let store = TestStore(initialState: Seen.State()) {
            Seen()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadData)
        let movieAdditionalFromDatabase: IdentifiedArrayOf = [
            additionalA.movieAdditional,
            additionalB.movieAdditional,
            additionalC.movieAdditional
        ]
        await store.receive(.updateMovieAdditional(Array(movieAdditionalFromDatabase)), timeout: 1) { state in
            state.additional = movieAdditionalFromDatabase
        }
        await store.receive(.loadMovies, timeout: 1)
        
        let moviesFromDatabase = [
            movieA.movie,
            movieB.movie,
            movieC.movie,
        ]
        
        var movieAWrapper = additionalA.movieAdditional
        movieAWrapper.movie = movieA.movie
        
        var movieBWrapper = additionalB.movieAdditional
        movieBWrapper.movie = movieB.movie
        
        var movieCWrapper = additionalC.movieAdditional
        movieCWrapper.movie = movieC.movie
        
        await store.receive(.updateMovies(moviesFromDatabase), timeout: 1) { state in
            state.additional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.receive(.sortMovies(nil), timeout: 1) { state in
            state.sortBy = .alphabeticallyAscending
            state.sortedAdditional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.send(.sortMovies(.ratingAscending)) { state in
            state.sortBy = .ratingAscending
            state.sortedAdditional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.send(.sortMovies(.ratingDecending)) { state in
            state.sortBy = .ratingDecending
            state.sortedAdditional = [
                movieCWrapper,
                movieBWrapper,
                movieAWrapper
            ]
        }
    }

    func testSortByRelease() async {
        
        let realm = try! await Realm()
        
        let idA = 1
        let additionalA = MovieAdditionalObject()
        additionalA.id = idA
        additionalA.customDescription = "customDescription"
        additionalA.customRating = 1
        additionalA.bookmarked = false
        additionalA.seen = true
        let movieA = MovieObject()
        movieA.id = idA
        movieA.title = "A"
        movieA.release = "2021-03-01"
        
        let idB = 2
        let additionalB = MovieAdditionalObject()
        additionalB.id = idB
        additionalB.customDescription = "customDescription"
        additionalB.customRating = 2
        additionalB.bookmarked = false
        additionalB.seen = true
        let movieB = MovieObject()
        movieB.id = idB
        movieB.title = "B"
        movieB.rating = 2
        movieB.release = "2022-03-02"
        
        let idC = 3
        let additionalC = MovieAdditionalObject()
        additionalC.id = idC
        additionalC.customDescription = "customDescription"
        additionalC.customRating = 3
        additionalC.bookmarked = false
        additionalC.seen = true
        let movieC = MovieObject()
        movieC.id = idC
        movieC.title = "C"
        movieC.rating = 3
        movieC.release = "2023-03-03"
        
        let idD = 4
        let additionalD = MovieAdditionalObject()
        additionalD.id = idD
        additionalD.customDescription = "customDescription"
        additionalD.customRating = 4
        additionalD.bookmarked = false
        additionalD.seen = false
        let movieD = MovieObject()
        movieD.id = idD
        movieD.title = "D"
        movieD.rating = 4
        movieD.release = "2024-03-04"
        
        
        try! realm.write {
            realm.add(additionalA)
            realm.add(movieA)
            
            realm.add(additionalB)
            realm.add(movieB)
            
            realm.add(additionalC)
            realm.add(movieC)
            
            realm.add(additionalD)
            realm.add(movieD)
        }
        
        let store = TestStore(initialState: Seen.State()) {
            Seen()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.loadData)
        let movieAdditionalFromDatabase: IdentifiedArrayOf = [
            additionalA.movieAdditional,
            additionalB.movieAdditional,
            additionalC.movieAdditional
        ]
        await store.receive(.updateMovieAdditional(Array(movieAdditionalFromDatabase)), timeout: 1) { state in
            state.additional = movieAdditionalFromDatabase
        }
        await store.receive(.loadMovies, timeout: 1)
        
        let moviesFromDatabase = [
            movieA.movie,
            movieB.movie,
            movieC.movie,
        ]
        
        var movieAWrapper = additionalA.movieAdditional
        movieAWrapper.movie = movieA.movie
        
        var movieBWrapper = additionalB.movieAdditional
        movieBWrapper.movie = movieB.movie
        
        var movieCWrapper = additionalC.movieAdditional
        movieCWrapper.movie = movieC.movie
        
        await store.receive(.updateMovies(moviesFromDatabase), timeout: 1) { state in
            state.additional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.receive(.sortMovies(nil), timeout: 1) { state in
            state.sortBy = .alphabeticallyAscending
            print(state.sortedAdditional.map({ $0.movie?.releaseDate }))
            state.sortedAdditional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
        
        await store.send(.sortMovies(.releaseDecending)) { state in
            state.sortBy = .releaseDecending
            print(state.sortedAdditional.map({ $0.movie?.releaseDate }))
            state.sortedAdditional = [
                movieCWrapper,
                movieBWrapper,
                movieAWrapper
            ]
        }
        
        await store.send(.sortMovies(.releaseAscending)) { state in
            state.sortBy = .releaseAscending
            state.sortedAdditional = [
                movieAWrapper,
                movieBWrapper,
                movieCWrapper
            ]
        }
    }
}
