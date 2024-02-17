//
//  ProgressCircle.swift
//  Vigor
//
//  Created by Casey Traina on 2/17/24.
//

import SwiftUI

struct ProgressCircle: View {
    // The progress value should be between 0 and 1
    var progress: CGFloat

    @State var color: Color = .black
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(color)
            
            // Foreground Circle
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270)) // Start from the top
                .animation(.linear, value: progress)
            
            // Percentage Text
            CustomText(text: String(format: "%.0f%%", progress * 100), size: 32, bold: true, alignment: .center, color: .black)
        }
        .onAppear {
            color = Color(red: (255.0 - progress*255)/255, green: progress, blue: 0)
        }
    }
}

#Preview {
    ProgressCircle(progress: 0.25)
        .frame(width: screenSize.width / 2, height: screenSize.height / 2)
    
}
