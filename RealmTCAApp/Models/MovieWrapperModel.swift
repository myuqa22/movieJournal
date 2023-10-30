//
//  MovieWrapperModel.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import Foundation

struct MovieWrapperModel: Equatable, Identifiable, Hashable, Codable {
    
    let id: Int
    var bookmarked: Bool
    var seen: Bool
    
    var customDescription: String
    var customRating: Double
    
    var movie: MovieModel?
    
    var movieAdditionalObject: MovieAdditionalObject {
        
        let movieAdditional = MovieAdditionalObject()
        movieAdditional.id = id
        movieAdditional.bookmarked = bookmarked
        movieAdditional.seen = seen
        movieAdditional.customDescription = customDescription
        movieAdditional.customRating = customRating
        
        return movieAdditional
    }
    
}

extension MovieWrapperModel {
    
    static var dummy: MovieWrapperModel {
        
        let movieModel = MovieModel(id: 1,
                                    title: "title",
                                    image: "/7VM1XHU6T8a4EMJnorMwEOX51Bd.jpg",
                                    rating: 2.0,
                                    overview: "overview",
                                    release_date: "23-11-02",
                                    genre_ids: [1])
        return MovieWrapperModel(id: 1,
                                 bookmarked: false,
                                 seen: false,
                                 customDescription: "abc",
                                 customRating: 2,
                                 movie: movieModel)
    }
}
