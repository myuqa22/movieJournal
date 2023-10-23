//
//  MovieModel.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Foundation

struct MovieModel: Equatable, Identifiable, Hashable, Codable {
    
    let id: UUID
    let title: String
    let image: String
    let rating: Double
    let overview: String
    let release_date: String
    
    var imageUrl: URL {
        URL(string: "https://image.tmdb.org/t/p/w500" + image)!
    }
    
    var movieObject: MovieObject {
        let movie = MovieObject()
        movie.id = id
        movie.title = title
        movie.image = image
        movie.rating = rating
        movie.overview = overview
        movie.release = release_date
        
        return movie
    }
}
