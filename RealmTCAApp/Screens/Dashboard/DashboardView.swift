//
//  DashboardView.swift
//  RealmTCAApp
//
//  Created by Privat on 20.10.23.
//

import SwiftUI

import ComposableArchitecture

// MARK: View
struct DashboardView: View {
    
    let store: StoreOf<Dashboard>
    
    var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                ZStack {
                    Color.gray.opacity(0.1).ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                Button(action: {
                                    viewStore.send(.goToSeen)
                                }, label: {
                                    Text("Gesehen")
                                        .padding()
                                        .tint(.white)
                                        .background(.purple)
                                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                })
                                Button(action: {
                                    viewStore.send(.goToWatchlist)
                                }, label: {
                                    Text("Watchlist")
                                        .padding()
                                        .tint(.white)
                                        .background(.purple)
                                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                })
                            }
                            FavoriteMoviesCaruselView(viewStore: viewStore)
                            TopRatedMovieCaruselView(viewStore: viewStore)
                            Spacer()
                        }
                    }
                    .navigationTitle("Übersicht")
                }
            }
        } destination: { path in
            switch path {
            case .dashboard:
                CaseLet(
                    /Dashboard.Path.State.dashboard,
                     action: Dashboard.Path.Action.dashboard,
                     then: DashboardView.init(store:)
                )
            case .seen:
                CaseLet(
                    /Dashboard.Path.State.seen,
                     action: Dashboard.Path.Action.seen,
                     then: SeenView.init(store:)
                )
            case .movie:
                CaseLet(
                    /Dashboard.Path.State.movie,
                     action: Dashboard.Path.Action.movie,
                     then: MovieView.init(store:)
                )
            case .watchlist:
                CaseLet(
                    /Dashboard.Path.State.watchlist,
                     action: Dashboard.Path.Action.watchlist,
                     then: WatchlistView.init(store:)
                )
            }
        }
    }
}

#Preview {
    DashboardView(
        store: Store(initialState: Dashboard.State(),
                     reducer: { Dashboard() })
    )
}

struct FavoriteMoviesCaruselView: View {
    
    let viewStore: ViewStore<Dashboard.State, Dashboard.Action>
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Beliebte Filme")
                    .font(.title3)
                Spacer()
                Button(action: {
                    viewStore.send(.loadPopularMovies)
                }, label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .tint(.black)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                })
            }
            .padding(.horizontal)
            .onAppear {
                viewStore.send(.getPopularMoviesFromDatabase)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewStore.popularMovies) { movie in
                        VStack {
                            AsyncImage(url: movie.imageUrl) { image in
                                image.image?
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            .frame(width: 150, height: 200)
                            Text(movie.title)
                                .font(.caption)
                                .frame(width: 150)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .onTapGesture {
                            viewStore.send(.gotToMovie(movie))
                        }
                    }
                }
            }
        }
        .padding(.vertical)
        .background(.white)
    }
}

struct TopRatedMovieCaruselView: View {
    
    let viewStore: ViewStore<Dashboard.State, Dashboard.Action>
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Beste Bewertung")
                    .font(.title3)
                Spacer()
                Button(action: {
                    viewStore.send(.loadTopRatedMovies)
                }, label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .tint(.black)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                })
            }
            .padding(.horizontal)
            .onAppear {
                viewStore.send(.getTopRatedMoviesFromDatabase)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewStore.topRatedMovies) { movie in
                        VStack {
                            AsyncImage(url: movie.imageUrl) { image in
                                image.image?
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            .frame(width: 150, height: 200)
                            Text(movie.title)
                                .font(.caption)
                                .frame(width: 150)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .onTapGesture {
                            viewStore.send(.gotToMovie(movie))
                        }
                    }
                }
            }
        }
        .padding(.vertical)
        .background(.white)
    }
}
