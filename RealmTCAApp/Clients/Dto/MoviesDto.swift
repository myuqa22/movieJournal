//
//  TopRatedMoviesDto.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import Foundation

struct MoviesDto: Codable {
    
    let page: Int
    let results: [MovieDto]
    let total_pages: Int
    let total_results: Int
    
}
