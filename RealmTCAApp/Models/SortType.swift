//
//  SortType.swift
//  RealmTCAApp
//
//  Created by Privat on 30.10.23.
//

import Foundation

enum SortType: String, Equatable, Hashable, Codable, CaseIterable, Identifiable {
    
    case alphabeticallyAscending = "Titel aufsteigend"
    case alphabeticallyDecending = "Titel absteigend"
    
    case ratingAscending = "Bewertung aufsteigend"
    case ratingDecending = "Bewertung absteigend"
    
    case customRatingAscendig = "Eigene Bewertung aufsteigend"
    case customRatingDecending  = "Eigene Bewertung absteigend"
    
    case releaseAscending = "Veröffentlichung aufsteigend"
    case releaseDecending = "Veröffentlichung absteigend"
    
    var id: Self { return self }
}
