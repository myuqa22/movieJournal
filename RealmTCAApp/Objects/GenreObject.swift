//
//  GenreObject.swift
//  RealmTCAApp
//
//  Created by Privat on 28.10.23.
//

import Foundation

import RealmSwift

class GenreObject: Object {
    
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
}

extension GenreObject {
    
    var genre: GenreModel {
        
        .init(id: id,
              name: name)
    }
    
}
