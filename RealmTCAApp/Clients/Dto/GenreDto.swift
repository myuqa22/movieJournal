//
//  GenreDto.swift
//  RealmTCAApp
//
//  Created by Privat on 28.10.23.
//

import Foundation

struct GenreDto: Codable {
    
    let id: Int
    let name: String
}

extension GenreDto {
    
    var genre: GenreObject {
        let genre = GenreObject()
        genre.id = id
        genre.name = name
        
        return genre
    }
}
