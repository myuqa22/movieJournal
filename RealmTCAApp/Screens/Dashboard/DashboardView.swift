//
//  DashboardView.swift
//  RealmTCAApp
//
//  Created by Privat on 20.10.23.
//

import SwiftUI

import ComposableArchitecture

struct DashboardView: View {
    
    let store: StoreOf<Dashboard>
    
    var body: some View {
        
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                ZStack {
                    Color.gray.opacity(0.1).ignoresSafeArea()
                    ScrollView {
                        VStack(spacing: .zero) {
                            UpperView(viewStore: viewStore)
                            
                            Group {
                                MoviesCaruselView(store: self.store.scope(state: \.popularMoviesCarusel,
                                                                          action: { childAction in
                                        .popularMoviesCarusel(childAction)
                                }))
                                
                                MoviesCaruselView(store: self.store.scope(state: \.topRatedMoviesCarusel,
                                                                          action: { childAction in
                                        .topRatedMoviesCarusel(childAction)
                                }))
                                
                                MoviesCaruselView(store: self.store.scope(state: \.nowPlayingMoviesCarusel,
                                                                          action: { childAction in
                                        .nowPlayingMoviesCarusel(childAction)
                                }))
                                
                                MoviesCaruselView(store: self.store.scope(state: \.animationMoviesCarusel,
                                                                          action: { childAction in
                                        .animationMoviesCarusel(childAction)
                                }))
                                
                                MoviesCaruselView(store: self.store.scope(state: \.documentationMoviesCarusel,
                                                                          action: { childAction in
                                        .documentationMoviesCarusel(childAction)
                                }))
                                
                                MoviesCaruselView(store: self.store.scope(state: \.loveMoviesCarusel,
                                                                          action: { childAction in
                                        .loveMoviesCarusel(childAction)
                                }))
                                
                                MoviesCaruselView(store: self.store.scope(state: \.horrorMoviesCarusel,
                                                                          action: { childAction in
                                        .horrorMoviesCarusel(childAction)
                                }))
                            }
                            
                            Spacer()
                        }
                    }
                    .navigationTitle("Übersicht")
                    .onAppear {
                        viewStore.send(.fetchGenreMovies)
                    }
                    .toolbar {
                      ToolbarItem(placement: .principal) { Color.clear }
                    }
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
            case .search:
                CaseLet(/Dashboard.Path.State.search,
                         action: Dashboard.Path.Action.search,
                         then: SearchView.init(store:))
            }
        }
        .accentColor(.white)
    }
    
    struct UpperView: View {
        
        let viewStore: ViewStore<Dashboard.State, Dashboard.Action>
        
        var body: some View {
            
            HStack {
                Button(action: {
                    viewStore.send(.goToSeen)
                }, label: {
                    Text("Gesehen")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .tint(.black)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        
                })
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    viewStore.send(.goToWatchlist)
                }, label: {
                    Text("Watchlist")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .tint(.black)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        
                })
                .frame(maxWidth: .infinity)
                Button(action: {
                    viewStore.send(.goToSearch)
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding()
                        .tint(.black)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                })
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
    }
    
}

#Preview {
    
    DashboardView(
        store: Store(initialState: Dashboard.State(),
                     reducer: { Dashboard() })
    )
}
