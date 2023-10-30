//
//  MovieCellView.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import SwiftUI

struct MovieCellView: View {
    
    let movieWrapper: MovieWrapperModel
    let genre: GenreModel?
    
    let cellHeight = Constants.movieCellHeigth
    
    var body: some View {
        
        HStack {
            AsyncImage(url: movieWrapper.movie?.imageUrl) { image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(height: cellHeight)
            VStack {
                Text(movieWrapper.movie?.title ?? String())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    if let genreName = genre?.name {
                        Text(genreName)
                        Text("·")
                    }
                    if let year = movieWrapper.movie?.year {
                        Text(verbatim: "\(year)")
                    }
                    Spacer()
                }
                .modifier(MovieCaption())
            }
            .frame(height: cellHeight)
            Spacer()
            VStack {
                Text(String(format: "%.1f", movieWrapper.movie?.rating ?? .zero))
                    .font(.body)
                    .foregroundStyle(.white)
                Text("TMBA")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
           
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.black)
    }
    
}

#Preview {
    
    MovieCellView(
        movieWrapper: MovieWrapperModel.dummy,
        genre: GenreModel(id: 1, name: "Genre"))
}
