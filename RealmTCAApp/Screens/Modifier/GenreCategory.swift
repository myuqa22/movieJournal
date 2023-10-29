//
//  GenreCategory.swift
//  RealmTCAApp
//
//  Created by Privat on 29.10.23.
//

import SwiftUI

struct GenreCategory: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.white)
            .foregroundColor(.black)
            .cornerRadius(20)
    }
    
}
