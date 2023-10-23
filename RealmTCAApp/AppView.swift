//
//  RealmTCAAppApp.swift
//  RealmTCAApp
//
//  Created by Privat on 20.10.23.
//

import SwiftUI

import ComposableArchitecture
import netfox

@main
struct AppView: App {
    var body: some Scene {
        WindowGroup {
            DashboardView(
                store: Store(initialState: Dashboard.State()) {
                    Dashboard()._printChanges()
                }
            )
            .onAppear {
                NFX.sharedInstance().start()
            }
        }
    }
}
