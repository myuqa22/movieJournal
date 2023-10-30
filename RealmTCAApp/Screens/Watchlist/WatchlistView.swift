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
            HStack {
                Spacer()
                Picker("Filter", selection: viewStore.binding(get: \.sortBy, send: {.sortMovies($0)})) {
                    ForEach(SortType.allCases) { filterType in
                        Text(filterType.rawValue)
                            .tag(filterType)
                    }
                }
                .pickerStyle(.menu)
            }
            
            ScrollView {
                VStack {
                    ForEach(viewStore.state.sortedAdditional) { additional in
                        if let movie = additional.movie {
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
            }
            .toolbar {
                ToolbarItem(placement: .principal) { Color.clear }
            }
            .padding(.horizontal)
            .onAppear {
                viewStore.send(.loadAdditional)
                viewStore.send(.loadGenres)
                viewStore.send(.sortMovies())
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
