//
//  Realm+Actions.swift
//  RealmTCAApp
//
//  Created by Privat on 21.10.23.
//

import Foundation
import Combine
import RealmSwift
import ComposableArchitecture
import SwiftUI

extension Realm {
    
    func fetch<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) -> Effect<Results<T>> {
        let promise = Future<Results<T>, Never> { completion in
            
            let objects = self.objects(type)
            if let predicate = predicate {
                completion(.success(objects.filter(predicate)))
                return
            }
            completion(.success(objects))
        }
        return Effect.publisher(promise.eraseToAnyPublisher)
    }
    
    
    func save<T: Object>(_ type: T.Type, value: [String: Any]) -> Effect<Signal> {
        let promise = Future<Signal, Never> { completion in
            do {
                try self.write {
                    self.create(type, value: value, update: .modified)
                }
                completion(.success(.success))
            } catch {
                //                completion(.failure(.failed))
                // TODO: Error handling
            }
        }
        
        return Effect.publisher(promise.eraseToAnyPublisher)
    }
    
    func save<T: Object>(_ objects: [T]) throws {
        
        try self.write {
            self.add(objects, update: .modified)
        }
    }
    
    func save<T: Object>(_ object: T) -> Effect<Signal> {
        let promise = Future<Signal, Never> { completion in
            do {
                try self.write {
                    self.create(T.self, value: object, update: .modified)
                }
                completion(.success(.signal))
            } catch {
                //                completion(.failure(AppError.unableToSave))
                // TODO: Error handling
            }
        }
        return Effect.publisher(promise.eraseToAnyPublisher)
    }
    
    func create<T: Object>(_ type: T.Type, object: T) -> Effect<T> {
        let promise = Future<T, Never> { completion in
            do {
                try self.write({
                    self.add(object)
                })
                completion(.success(object))
            } catch {
                //                completion(.failure(.))
                // TODO: Error handling
            }
        }
        return Effect.publisher(promise.eraseToAnyPublisher)
    }
}
