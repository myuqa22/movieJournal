//
//  SeenView.swift
//  RealmTCAApp
//
//  Created by Privat on 20.10.23.
//

import SwiftUI

import ComposableArchitecture
import RealmSwift

struct SeenView: View {
    
    let store: StoreOf<Seen>
    
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
            .navigationTitle("Gesehen")
            .onAppear {
                viewStore.send(.loadData)
                viewStore.send(.loadGenres)
                viewStore.send(.sortMovies())
            }
        }
    }
    
}

#Preview {
    
    SeenView(store: Store(initialState: Seen.State.init(), reducer: {
        Seen()
    }))
}
