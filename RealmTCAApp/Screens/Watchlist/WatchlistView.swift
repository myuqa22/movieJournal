//
//  WatchlistView.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import SwiftUI

import ComposableArchitecture

struct WatchlistView: View {
    
    let store: StoreOf<Watchlist>
    
    var body: some View {
        
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack {
                    ForEach(viewStore.state.movies) { movie in
                        Button(action: {
                            viewStore.send(.detailMovieButtonTapped(movie))
                        }, label: {
                            if let firstGenreId = movie.genre_ids.first,
                               let genre = viewStore.state.genres.first(where: { $0.id == firstGenreId }) {
                                MovieCellView(movie: movie, genre: genre)
                            } else {
                                MovieCellView(movie: movie, genre: nil)
                            }
                        })
                    }
                }
            }
            .toolbar {
              ToolbarItem(placement: .principal) { Color.clear }
            }
            .padding(.horizontal)
            .onAppear {
                viewStore.send(.loadAdditional)
                viewStore.send(.loadGenres)
            }
            .navigationTitle("Watchlist")
        }
    }
    
}

#Preview {
    
    WatchlistView(store: Store(initialState: Watchlist.State(), reducer: {
        Watchlist()
    }))
}
