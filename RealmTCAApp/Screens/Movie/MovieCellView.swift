//
//  MovieCellView.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import SwiftUI

struct MovieCellView: View {
    
    let movie: MovieModel
    
    var body: some View {
        HStack {
            AsyncImage(url: movie.imageUrl) { image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 50)
            Text(movie.title)
            Spacer()
            Text(String(format: "%.1f", movie.rating))
        }
        .foregroundStyle(.black)
    }
}

#Preview {
    MovieCellView(movie: MovieModel(id: UUID(), title: "abc", image: "", rating: 2.0, overview: "", release_date: ""))
}