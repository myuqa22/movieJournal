//
//  MovieAdditionalModel.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import Foundation

struct MovieAdditionalModel: Equatable, Identifiable, Hashable, Codable {
    
    let id: UUID
    var bookmarked: Bool
    var seen: Bool
    
    var customDescription: String
    var customRating: Double
    
    var movieAdditionalObject: MovieAdditionalObject {
        let movieAdditional = MovieAdditionalObject()
        movieAdditional.id = id
        movieAdditional.favorite = bookmarked
        movieAdditional.seen = seen
        movieAdditional.customDescription = customDescription
        movieAdditional.customRating = customRating
        
        return movieAdditional
    }
}