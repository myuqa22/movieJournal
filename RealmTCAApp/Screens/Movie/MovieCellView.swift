//
//  MovieCellView.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import SwiftUI

struct MovieCellView: View {
    
    let movie: MovieModel
    let genre: GenreModel?
    
    var body: some View {
        HStack {
            AsyncImage(url: movie.imageUrl) { image in
                image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            VStack {
                Text(movie.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    if let genreName = genre?.name {
                        Text(genreName)
                        Text("·")
                    }
                    if let year = movie.year {
                        Text(verbatim: "\(year)")
                    }
                    Spacer()
                }
                .modifier(MovieCaption())
            }
            .frame(height: 100)
            Spacer()
            Text(String(format: "%.1f", movie.rating))
                .font(.body)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.black)
    }
    
}

#Preview {
    
    List(0 ..< 5) { item in
        MovieCellView(
            movie: MovieModel(id: 1,
                              title: "title",
                              image: "/7VM1XHU6T8a4EMJnorMwEOX51Bd.jpg",
                              rating: 2.0,
                              overview: "overview",
                              release_date: "23-11-02",
                              genre_ids: [1]),
            genre: GenreModel(id: 1, name: "Genre"))
    }
    .listStyle(.plain)
}
