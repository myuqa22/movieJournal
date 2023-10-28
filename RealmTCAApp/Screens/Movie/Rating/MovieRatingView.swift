//
//  MovieRatingView.swift
//  RealmTCAApp
//
//  Created by Privat on 27.10.23.
//

import SwiftUI

import ComposableArchitecture

struct MovieRatingView: View {
    
    let store: StoreOf<MovieRating>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                
                CircularProgressView(progress: viewStore.progress,
                                     maxProgress: viewStore.stepCount,
                                     lineWidth: 20)
                .overlay {
                    HStack(alignment: .center) {
                        Spacer()
                        VStack {
                            Text("Meine Bewertung")
                                .font(.title2)
                                .foregroundStyle(.white)
                            TextField(String(), value: viewStore.binding(get: \.progress,
                                                                         send: {
                                .changeProgress(Double($0))
                            }), formatter: Constants.formatter)
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .keyboardType(.numberPad)
                }
                .frame(width: 300)
                Slider(value: viewStore.$progress, in: 0...viewStore.state.stepCount)
                    .tint(.accentColor)
            }
            .padding()
            .onDisappear {
                viewStore.send(.saveCustomRating(viewStore.state.progress))
            }
        }
    }
}

#Preview {
    MovieRatingView(store: Store(initialState: MovieRating.State(progress: 0, stepCount: 1), reducer: {
        MovieRating()
    }))
}
