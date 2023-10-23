//
//  SeenView.swift
//  RealmTCAApp
//
//  Created by Privat on 20.10.23.
//

import SwiftUI

import RealmSwift
import ComposableArchitecture

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
                            MovieCellView(movie: movie)
                        })
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Gesehen")
            .onAppear {
                viewStore.send(.loadAdditional)
            }
            
        }
    }
}

#Preview {
    SeenView(store: Store(initialState: Seen.State.init(), reducer: {
        Seen()
    }))
}
