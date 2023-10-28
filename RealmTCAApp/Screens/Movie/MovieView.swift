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
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(viewStore.genres) { genre in
                                Text(genre.name)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(20)
                            }
                        }
        
                    }
                    .onAppear {
                        viewStore.send(.loadGenres)
                    }
                    Text(viewStore.movie.overview)
                    Spacer()
                }
                .padding(.horizontal)
                .toolbarTitleDisplayMode(.inline)
                .onAppear {
                    viewStore.send(.loadGenres)
                    viewStore.send(.loadOrCreateAdditional)
                }
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isSheetPresented,
                    send: { .setSheet(isPresented: $0) }
                )
            ) {
                IfLetStore(self.store.scope(state: \.movieRating,
                                            action: { .movieRating($0)})) {
                    MovieRatingView(store: $0)
                } else: {
                    ProgressView()
                }
                .presentationDetents([.medium])
                
            }
        }
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
                .padding(.leading)
                Spacer()
                VStack {
                    VStack {
                        Text("\(viewStore.state.movie.id)")
                        CircularProgressView(progress: viewStore.state.movie.rating, maxProgress: Constants.maxRating)
                            .overlay {
                                Text(String(format: "%.1f", viewStore.state.movie.rating))
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(Circle().foregroundColor(.black))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 60, height: 60)
                        
                        Text("TMBA")
                            .fontWeight(.bold)
                            .font(.caption2)
                    }
                    
                    VStack {
                        CircularProgressView(progress: viewStore.state.movieAdditional?.customRating ?? .zero,
                                             maxProgress: Constants.maxRating)
                            .overlay {
                                Text(String(format: "%.1f", viewStore.state.movieAdditional?.customRating ?? .zero))
                                    .fontWeight(.bold)
                                    .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
                                    .padding()
                                    .background(Circle().foregroundColor(.black))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 60, height: 60)
                        
                        
                        Text("Meine Bewertung")
                            .fontWeight(.bold)
                            .font(.caption2)
                    }
                    .onTapGesture {
                        viewStore.send(.setSheet(isPresented: true))
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
                        .background(.black)
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
                        .background(.black)
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
}



#Preview {
    MovieView(
        store: Store(
            initialState: Movie.State(
                movie: MovieModel(id: 1,
                                  title: "Movie",
                                  image: "",
                                  rating: 5,
                                  overview: "abc",
                                  release_date: "Datum",
                                  genre_ids: []),
                movieAdditional: MovieAdditionalModel(id: 1,
                                                      bookmarked: false,
                                                      seen: false,
                                                      customDescription: "",
                                                      customRating: 5),
            genres: [GenreModel(id: 2, name: "Abenteuer")]),
            reducer: {
                Movie()
            }
        ))
}
