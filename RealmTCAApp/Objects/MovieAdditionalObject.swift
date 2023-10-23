//
//  MovieAdditionalObject.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import RealmSwift
import Foundation

class MovieAdditionalObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var favorite: Bool
    @Persisted var seen: Bool
    @Persisted var customDescription: String
    @Persisted var customRating: Double
}

extension MovieAdditionalObject {
    
    var movieAdditional: MovieAdditionalModel {
        .init(id: id,
              bookmarked: favorite,
              seen: seen,
              customDescription: customDescription,
              customRating: customRating)
    }
}