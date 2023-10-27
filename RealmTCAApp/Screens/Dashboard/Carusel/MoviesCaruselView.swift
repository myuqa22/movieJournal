//
//  MoviesCaruselView.swift
//  RealmTCAApp
//
//  Created by Privat on 27.10.23.
//

import SwiftUI

import ComposableArchitecture

struct MoviesCaruselView: View {
    
    let store: StoreOf<MoviesCarusel>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: .zero) {
                HStack {
                    Text(viewStore.state.category.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .tint(.white)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .onAppear {
                    viewStore.send(.fetchMovies)
                }
                
                ScrollView(.horizontal) {
                    HStack(spacing: 5) {
                        ForEach(viewStore.movies) { movie in
                            VStack {
                                AsyncImage(url: movie.imageUrl) { image in
                                    image.image?
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                .frame(width: 120)
                                Text(movie.title)
                                    .font(.caption)
                                    .frame(width: 120)
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                Spacer()
                            }
                            .onTapGesture {
                                viewStore.send(.gotToMovie(movie))
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(.top)
            .background(.black)
        }
    }
}

#Preview {
    MoviesCaruselView(store: Store(initialState: MoviesCarusel.State.init(category: .popular), reducer: {
        MoviesCarusel()
    }))
}
