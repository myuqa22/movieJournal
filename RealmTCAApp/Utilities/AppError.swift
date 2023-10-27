//
//  AppError.swift
//  RealmTCAApp
//
//  Created by Privat on 23.10.23.
//

import Foundation

enum AppError: Error, Equatable {
    
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        true
    }

    case decodedError
    case writeDatabaseError
    case other(Error)
}

