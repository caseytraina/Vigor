//
//  OverallWarning.swift
//  Vigor
//
//  Created by Filip Henriksson on 17.02.24.
//

import Foundation

import SwiftUI

struct ProgressBar: View {
    var score: CGFloat = 80 // Default score set to 80
    
    private var progressBarColor: Color {
        switch score {
        case 0..<30:
            return .red
        case 30..<60:
            return .yellow
        default:
            return .green
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 20)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: min(score/100.0 * geometry.size.width, geometry.size.width), height: 20)
                    .foregroundColor(progressBarColor)
                    .animation(.linear, value: score)
            }
            .cornerRadius(45.0)
        }
    }
}
