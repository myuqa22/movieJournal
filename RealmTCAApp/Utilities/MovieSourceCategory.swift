//
//  MovieSourceCategory.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import Foundation

enum MovieSourceCategoryType: Codable, Hashable {
    
    case popular
    case topRated
    case nowPlaying
    case genre(GenreModel)
    
    var title: String {
        
        switch self {
        case .popular:
            return "Derzeit beliebt"
        case .topRated:
            return "Top Filme"
        case .nowPlaying:
            return "Neuerscheinungen"
        case let .genre(genreModel):
            return genreModel.name
        }
    }
    
}
