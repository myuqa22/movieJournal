//
//  MovieObject.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Foundation

import RealmSwift

class MovieSourceCategory: Object {
    
    @Persisted var category: String
}

class MovieObject: Object {
    
    @Persisted(primaryKey: true) var id: Int
    @Persisted var title: String
    @Persisted var rating: Double
    @Persisted var image: String?
    @Persisted var overview: String
    @Persisted var release: String
    @Persisted var genre_ids: List<Int>
    
    @Persisted var categories: List<MovieSourceCategory>
}

extension MovieObject {
    
    var movie: MovieModel {
        
        .init(id: id,
              title: title,
              image: image,
              rating: rating, 
              overview: overview,
              release_date: release,
              genre_ids: Array(genre_ids))
    }
    
}
