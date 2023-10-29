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
            .navigationTitle("Gesehen")
            .onAppear {
                viewStore.send(.loadData)
                viewStore.send(.loadGenres)
            }
        }
    }
    
}

#Preview {
    
    SeenView(store: Store(initialState: Seen.State.init(), reducer: {
        Seen()
    }))
}
