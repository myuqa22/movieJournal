//
//  Realm+Actions.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Combine
import Foundation

import ComposableArchitecture
import RealmSwift
import SwiftUI

extension Realm {
    
    func fetch<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) -> Effect<Results<T>> {
        
        let promise = Future<Results<T>, Never> { promise in
            let objects = self.objects(type)
            if let predicate = predicate {
                promise(.success(objects.filter(predicate)))
                return
            }
            promise(.success(objects))
        }
        return Effect.publisher(promise.eraseToAnyPublisher)
    }
    
    func save<T: Object>(_ objects: [T]) -> Effect<Signal> {
        
        let promise = Future<Signal, Never> { promise in
            do {
                try self.write {
                    self.add(objects, update: .modified)
                }
                return promise(.success(.success))
            } catch {
                print(error)
                return promise(.success(.failure(AppError.writeDatabaseError)))
            }
        }.eraseToAnyPublisher
        
        return Effect.publisher(promise)
    }
    
    func save<T: Object>(_ object: T) -> Effect<Signal> {
        
        let promise = Future<Signal, Never> { promise in
            do {
                try self.write {
                    self.create(T.self, value: object, update: .modified)
                }
                return promise(.success(.success))
            } catch {
                return promise(.success(.failure(AppError.writeDatabaseError)))
            }
        }.eraseToAnyPublisher
        
        return Effect.publisher(promise)
    }
    
    func create<T: Object>(_ type: T.Type, object: T) -> Effect<Signal> {
        
        let promise = Future<Signal, Never> { promise in
            do {
                try self.write {
                    self.add(object)
                }
                promise(.success(.success))
            } catch {
                promise(.success(.failure(.writeDatabaseError)))
            }
        }
        return Effect.publisher(promise.eraseToAnyPublisher)
    }
    
}
