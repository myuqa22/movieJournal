//
//  PopularMoviesDto.swift
//  RealmTCAApp
//
//  Created by Privat on 22.10.23.
//

import Foundation

struct PopularMoviesDto: Codable {    
    
    let page: Int
    let results: [MovieDto]
    let total_pages: Int
    let total_results: Int
    
    // https://image.tmdb.org/t/p/w500/wwemzKWzjKYJFfCeiB57q3r4Bcm.png
    struct MovieDto: Codable {
        let id: Int
        let title: String
        let overview: String
        let poster_path: String
        let release_date: String
        let vote_average: Double
        
        var movieObject: MovieObject {
            let movie = MovieObject()
            movie.id = UUID(self.id)
            movie.title = title
            movie.image = poster_path
            movie.rating = vote_average
            movie.overview = overview
            movie.release = release_date
            
            return movie
        }
    }
}
