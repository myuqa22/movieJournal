//
//  Date+Component.swift
//  RealmTCAApp
//
//  Created by Privat on 29.10.23.
//

import Foundation

extension Date {
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        
        calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        
        calendar.component(component, from: self)
    }
    
}
