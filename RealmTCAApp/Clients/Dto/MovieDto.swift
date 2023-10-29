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
    let poster_path: String?
    let release_date: String
    let vote_average: Double
    
    let genre_ids: [Int]
    
}

extension MovieDto {
    
    var movieObject: MovieObject {
        
        let movie = MovieObject()
        movie.id = self.id
        movie.title = title
        movie.image = poster_path
        movie.rating = vote_average
        movie.overview = overview
        movie.release = release_date
        movie.genre_ids.append(objectsIn: genre_ids)
        
        return movie
    }
    
    var movieModel: MovieModel {
        
        MovieModel(id: id,
                   title: title,
                   image: poster_path,
                   rating: vote_average,
                   overview: overview,
                   release_date: release_date,
                   genre_ids: genre_ids)
    }
    
}
