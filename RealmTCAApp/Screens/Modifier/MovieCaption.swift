//
//  MovieCaption.swift
//  RealmTCAApp
//
//  Created by Privat on 29.10.23.
//

import SwiftUI

struct MovieCaption: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundStyle(.gray)
    }
    
}
