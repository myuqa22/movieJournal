//
//  Dashboard+Path.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Foundation

import ComposableArchitecture

extension Dashboard {
    
    struct Path: Reducer {
        
        enum State: Equatable, Hashable, Codable {
            
            case dashboard(Dashboard.State = .init())
            case seen(Seen.State = .init())
            case watchlist(Watchlist.State = .init())
            case movie(Movie.State)
            case search(Search.State = .init())
        }
        
        enum Action {
            
            case dashboard(Dashboard.Action)
            case seen(Seen.Action)
            case watchlist(Watchlist.Action)
            case movie(Movie.Action)
            case search(Search.Action)
        }
        
        var body: some Reducer<State, Action> {
            
            Scope(state: /State.watchlist, action: /Action.watchlist) {
                Watchlist()
            }
            Scope(state: /State.dashboard, action: /Action.dashboard) {
                Dashboard()
            }
            Scope(state: /State.seen, action: /Action.seen) {
                Seen()
            }
            Scope(state: /State.movie, action: /Action.movie) {
                Movie()
            }
            Scope(state: /State.search, action: /Action.search) {
                Search()
            }
        }
    }
    
}
