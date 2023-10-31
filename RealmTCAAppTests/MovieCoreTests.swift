//
//  MovieCoreTests.swift
//  RealmTCAAppTests
//
//  Created by Privat on 31.10.23.
//

import XCTest

import ComposableArchitecture
import RealmSwift

@testable import RealmTCAApp

@MainActor
final class MovieCoreTests: XCTestCase {

    override func setUp() {
        
        super.setUp()
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = String(describing: self)
    }

}
