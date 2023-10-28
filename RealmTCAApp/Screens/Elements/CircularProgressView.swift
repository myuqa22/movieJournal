//
//  CircularProgressView.swift
//  RealmTCAApp
//
//  Created by Privat on 27.10.23.
//

import SwiftUI

struct CircularProgressView: View {
    
    let progress: CGFloat
    let maxProgress: CGFloat
    var lineWidth: CGFloat = 5
    
    var foregroundColor: Color {
        
        let quarterOf = maxProgress / 4
        if progress < quarterOf {
            return .red
        } else if progress < quarterOf * 2 {
            return .orange
        } else if progress < quarterOf * 3 {
            return .yellow
        } else {
            return .green
        }
    }
    
    var body: some View {
        
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .opacity(0.2)
                .foregroundColor(.white)
            Circle()
                .trim(from: 0.0, to: min(progress / maxProgress, 1))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(foregroundColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
                .animation(.linear, value: foregroundColor)
        }
    }
    
}

#Preview {
    
    CircularProgressView(progress: 10, maxProgress: 10, lineWidth: 20)
}
