//
//  Formatter.swift
//  RealmTCAApp
//
//  Created by Privat on 30.10.23.
//

import Foundation

final class Formatter {
    
    static let oneMaximumFractionDigits: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    static let dateMediumString: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        return dateFormatter
    }()
}
