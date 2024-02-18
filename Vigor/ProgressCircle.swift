//
//  ProgressCircle.swift
//  Vigor
//
//  Created by Casey Traina on 2/17/24.
//

import SwiftUI

struct ProgressCircle: View {
    // The progress value should be between 0 and 1
    @Binding var progress: Int

    @State var color: Color = .black
    
    @State var adjusted: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background Circle
                Circle()
                    .stroke(lineWidth: geo.size.width * 0.2)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                    .frame(width: geo.size.width, height: geo.size.width)

                
                // Foreground Circle
                Circle()
                    .trim(from: 0.0, to: adjusted)
                    .stroke(style: StrokeStyle(lineWidth: geo.size.width * 0.15, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(Gradient(colors: [.purple, .blue]))
                    .rotationEffect(Angle(degrees: 270)) // Start from the top
                    .animation(.linear, value: progress)
                    .frame(width: geo.size.width, height: geo.size.width)

                
                HStack {
                    Image(systemName: "arrow.up.right")
                        .resizable()
                        .frame(width: geo.size.width * 0.1, height: geo.size.width * 0.1)
                    CustomText(text: String(format: "%.0f%", progress * 100), size: geo.size.width * 0.2, bold: true, alignment: .center, color: .black)
                }
            }
            .frame(width: geo.size.width, height: geo.size.width)
            .onAppear {
                
                adjusted = CGFloat(min(progress,100)/100)
                color = Color(red: (255.0 - Double(progress*255))/255, green: Double(progress), blue: 0)
            }
        }
    }
}

