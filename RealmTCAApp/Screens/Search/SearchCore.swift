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
        
        @BindingState var searchInput: String
    }
    
    enum Action: BindableAction, Equatable {
        
        case binding(BindingAction<State>)
        case changeSearchInput(String)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            }
        }
        
    }
}
