//
//  MovieDto.swift
//  RealmTCAApp
//
//  Created by Privat on 27.10.23.
//

import Foundation

struct MovieDto: Codable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
    let release_date: String
    let vote_average: Double
    
    var movieObject: MovieObject {
        let movie = MovieObject()
        movie.id = self.id
        movie.title = title
        movie.image = poster_path
        movie.rating = vote_average
        movie.overview = overview
        movie.release = release_date
        
        return movie
    }
}
