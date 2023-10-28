//
//  SearchView.swift
//  RealmTCAApp
//
//  Created by Privat on 28.10.23.
//

import SwiftUI

struct SearchView: View {
    
    @State var searchableString: String = String()
    
    var body: some View {
        List {
//            ForEach(1..<99) { num in
//                Text("Hallo \(num)")
//            }
            HStack {
                Spacer()
                Text("Über das Suchfeld können nach Filmen gesucht werden 🎬")
                    .multilineTextAlignment(.center)
                Spacer()
            }.frame(height: 200)
        }
        .listStyle(.plain)
        .navigationTitle("Suche")
        .searchable(text: $searchableString)
        .onSubmit(of: .search) {
            print(searchableString)
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    
}
