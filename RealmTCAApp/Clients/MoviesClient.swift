//
//  MoviesClient.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Foundation

import ComposableArchitecture

struct MoviesClient {
    var popularMovies: @Sendable () async throws -> MoviesDto
    var topRatedMovies:  @Sendable () async throws -> MoviesDto
    var nowPlayingMovies: @Sendable () async throws -> MoviesDto
    var genreMovies: @Sendable () async throws -> GenresDto
}

extension DependencyValues {
  var moviesClient: MoviesClient {
    get { self[MoviesClient.self] }
    set { self[MoviesClient.self] = newValue }
  }
}

extension MoviesClient: DependencyKey {
    
    static var bearer = Bundle.main.object(forInfoDictionaryKey: "BEARER_TOKEN") as! String
    
    static let liveValue = Self(
        popularMovies: {
            try await Task.sleep(for: .seconds(1))
            
            var url = URL(string: "https://api.themoviedb.org/3/discover/movie?language=de-GER")!
        
            var request = URLRequest(url: url)
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared
                .data(for: request)
            let decoded = try JSONDecoder().decode(MoviesDto.self, from: data)
            
            return decoded
        }, topRatedMovies: {
            try await Task.sleep(for: .seconds(1))
            
            var url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?language=de-GER")!
        
            var request = URLRequest(url: url)
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared
                .data(for: request)
            let decoded = try JSONDecoder().decode(MoviesDto.self, from: data)
            
            return decoded
            
        }, nowPlayingMovies: {
            try await Task.sleep(for: .seconds(1))
            
            var url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?language=de-GER")!
        
            var request = URLRequest(url: url)
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared
                .data(for: request)
            let decoded = try JSONDecoder().decode(MoviesDto.self, from: data)
            
            return decoded
        }, genreMovies: {
            try await Task.sleep(for: .seconds(1))
            
            var url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?language=de")!
        
            var request = URLRequest(url: url)
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared
                .data(for: request)
            let decoded = try JSONDecoder().decode(GenresDto.self, from: data)
            
            return decoded
        }
    )

    /// This is the "unimplemented" fact dependency that is useful to plug into tests that you want
    /// to prove do not need the dependency.
    static let testValue = Self(
        popularMovies: unimplemented("\(Self.self).popularMovies"),
        topRatedMovies: unimplemented("\(Self.self).topRatedMovies"),
        nowPlayingMovies: unimplemented("\(Self.self).nowPlayingMovies"),
        genreMovies: unimplemented("\(Self.self).genreMovies")
    )
}
