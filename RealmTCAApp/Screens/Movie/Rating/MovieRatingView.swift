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
                            TextField(String(),
                                      value: viewStore.binding(
                                        get: \.progress,
                                        send: {
                                            .changeProgress(Double($0))
                                        }),
                                      formatter: Formatter.oneMaximumFractionDigits)
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                        }
                        Spacer()
                    }
                }
                .frame(width: 300)
                Slider(value: viewStore.binding(get: \.progress, send: {
                    .changeProgress($0)
                }), in: 0...viewStore.state.stepCount)
                    .tint(.white)
                    .padding(.horizontal)
                Button(action: {
                    viewStore.send(.saveButtonTapped)
                }, label: {
                    Text("Speichern")
                        .padding()
                        .foregroundStyle(.black)
                        .background(.white)
                        .cornerRadius(30)
                })
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
