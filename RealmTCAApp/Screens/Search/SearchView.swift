//
//  SearchView.swift
//  RealmTCAApp
//
//  Created by Privat on 28.10.23.
//

import SwiftUI

import ComposableArchitecture

struct SearchView: View {
    
    let store: StoreOf<Search>
    
    var body: some View {
        
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                if viewStore.searchResults.isEmpty {
                    HStack {
                        Spacer()
                        if viewStore.searchInput.isEmpty {
                            Text("Über das Suchfeld können nach Filmen gesucht werden 🎬")
                        } else {
                            Text("Keine Ergebnisse")
                        }
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                    .frame(height: 200)
                } else {
                    ForEach(viewStore.searchResults) { movie in
                        MovieCellView(movie: movie, genre: nil)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Filme suchen")
            .searchable(
                text: viewStore.binding(
                    get: \.searchInput,
                    send: {
                        .updateSearchQuery($0)
                    }),
                placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                viewStore.send(.searchMovies)
            }
            .toolbar {
                ToolbarItem(placement: .principal) { Color.clear }
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        SearchView(store: Store(initialState: Search.State.init(), reducer: {
            Search()
        }))
    }
    
}
