//
//  Constants.swift
//  RealmTCAApp
//
//  Created by Privat on 28.10.23.
//

import Foundation

final class Constants {
    
    static let maxRating: CGFloat = 10
    
    static let oneMaximumFractionDigitsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()
}
