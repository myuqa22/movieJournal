//
//  MovieModel.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Foundation

import RealmSwift

struct MovieModel: Equatable, Identifiable, Hashable, Codable {
    
    let id: Int
    let title: String
    let image: String?
    let rating: Double
    let overview: String
    let release_date: String
    let genre_ids: [Int]
    
    var imageUrl: URL? {
        
        guard let image = movieObject.image else {
            return nil
        }
        return URL(string: "https://image.tmdb.org/t/p/w500" + image)
    }
    
    var movieObject: MovieObject {
        
        let movie = MovieObject()
        movie.id = id
        movie.title = title
        movie.image = image
        movie.rating = rating
        movie.overview = overview
        movie.release = release_date
        movie.genre_ids.append(objectsIn: genre_ids)
    
        return movie
    }
    
    var releaseDate: Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        return formatter.date(from: release_date)
    }
    
    var year: Int? {
        releaseDate?.get(.year)
    }
    
}
