//
//  MovieView.swift
//  RealmTCAApp
//
//  Created by Privat on 20.10.23.
//

import SwiftUI

import ComposableArchitecture

struct MovieView: View {
    
    let store: StoreOf<Movie>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack {
                    Text(viewStore.movie.title)
                        .font(.largeTitle)
                    UpperView(viewStore: viewStore)
                    Text(viewStore.movie.overview)
                    Spacer()
                }
                .padding(.horizontal)
                .toolbarTitleDisplayMode(.inline)
                .onAppear {
                    viewStore.send(.load)
                }
            }
        }
    }
}

#Preview {
    MovieView(
        store: Store(
            initialState: Movie.State(movie: MovieModel(id: UUID(),
                                                        title: "Movie",
                                                        image: "",
                                                        rating: 5, 
                                                        overview: "abc",
                                                        release_date: "Datum"),
                                      movieAdditional: MovieAdditionalModel(id: UUID(),
                                                                            bookmarked: false,
                                                                            seen: false,
                                                                            customDescription: "",
                                                                            customRating: 5)),
            reducer: {
                Movie()
            }
        ))
}

struct UpperView: View {
    
    let viewStore: ViewStore<Movie.State, Movie.Action>
    
    var body: some View {
        HStack(spacing: .zero) {
            AsyncImage(url: viewStore.movie.imageUrl) { image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(height: 350)
            .background(.blue)
            .padding(.leading)
            Spacer()
            VStack {
                VStack {
                    Text(String(format: "%.1f", viewStore.state.movie.rating))
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 60, height: 60)
                        .background(.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                    Text("TMBA")
                        .fontWeight(.bold)
                        .font(.caption2)
                }
               
                VStack {
                    Text(String(format: "%.1f", viewStore.state.movieAdditional?.customRating ?? .zero))
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 60, height: 60)
                        .background(.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                    Text("Meine Bewertung")
                        .fontWeight(.bold)
                        .font(.caption2)
                }
               
                VStack {
                    Button(action: {
                        viewStore.send(.watchlistButtonTapped)
                    }, label: {
                        Image(systemName: "\(viewStore.movieAdditional?.bookmarked ?? false ? "bookmark.fill" : "bookmark")")
                            .font(.title)
                    })
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(.purple)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    Text("\(viewStore.movieAdditional?.bookmarked ?? false ? "In Watchlist" : "Speichern")")
                        .fontWeight(.bold)
                        .font(.caption2)
                }
                Spacer()
                VStack {
                    Button(action: {
                        viewStore.send(.seenButtonTapped)
                    }, label: {
                        Image(systemName: "\(viewStore.movieAdditional?.seen ?? false ? "checkmark" : "eye")")
                            .font(.title)
                    })
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(.purple)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    Text("\(viewStore.movieAdditional?.seen ?? false ? "Gesehen" : "Nicht gesehen")")
                        .fontWeight(.bold)
                        .font(.caption2)
                }.padding(.horizontal)
            
                Spacer()
            }
            Spacer()
        }
    }
}
