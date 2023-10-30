//
//  MovieAdditionalObject.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import Foundation

import RealmSwift

class MovieAdditionalObject: Object {
    
    @Persisted(primaryKey: true) var id: Int
    @Persisted var bookmarked: Bool
    @Persisted var seen: Bool
    @Persisted var customDescription: String
    @Persisted var customRating: Double
}

extension MovieAdditionalObject {
    
    var movieAdditional: MovieWrapperModel {
        
        .init(id: id,
              bookmarked: bookmarked,
              seen: seen,
              customDescription: customDescription,
              customRating: customRating)
    }
    
}
