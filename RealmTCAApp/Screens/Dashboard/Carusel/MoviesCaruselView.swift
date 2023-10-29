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
    
    let movieWidth = Constants.movieCaruselWidth
    
    var body: some View {
        
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: .zero) {
                HStack(alignment: .center) {
                    Text(viewStore.state.category.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .tint(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: {}, label: {
                        Text("Alle ansehen")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white, lineWidth: 1)
                            )
                    })
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        Spacer()
                            .frame(width: .zero)
                        ForEach(viewStore.movies) { movie in
                            VStack {
                                AsyncImage(url: movie.imageUrl) { image in
                                    image.image?
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .frame(width: movieWidth)
                                
                                Text(movie.title)
                                    .font(.caption)
                                    .frame(width: movieWidth, alignment: .leading)
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                HStack(spacing: 2) {
                                    if let firstGenreId = movie.genre_ids.first,
                                    let genreString = viewStore.state.genres.first(where: { $0.id == firstGenreId})?.name {
                                        Text(genreString)
                                        Text("·")
                                            .fontWeight(.bold)
                                    }
                                    if let movieReleaseDate = movie.releaseDate {
                                        Text(verbatim: "\(movieReleaseDate.get(.year))")
                                    }
                                   
                                    Spacer()
                                }
                                .modifier(MovieCaption())
                                
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
            .onAppear {
                viewStore.send(.getMovieGenresFromDatabase)
                viewStore.send(.fetchMovies)
                
            }
        }
    }
    
}

#Preview {
    
    MoviesCaruselView(store: Store(initialState: MoviesCarusel.State.init(category: .popular), reducer: {
        MoviesCarusel()
    }))
}
