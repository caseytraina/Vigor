//
//  CustomText.swift
//  Vigor
//
//  Created by Casey Traina on 2/17/24.
//

import SwiftUI

struct CustomText: View {
    var text: String
    var size: CGFloat
    var bold: Bool
    var alignment: TextAlignment
    var color: Color
    
    
    init(text: String, size: CGFloat, bold: Bool, alignment: TextAlignment, color: Color) {
        self.size = size
        self.bold = bold
        self.alignment = alignment
        self.text = text
        self.color = color
    }
    // A generalized text since Apple doesn't support a default text functionality
    // Allows user to input a string, font size, bold/unbold, and alignment
    var body: some View {
            Text(text)
                .foregroundColor(color)
                .font(Font.custom(bold ? "CircularStd-Black" : "CircularStd-Book", size: size))
                .multilineTextAlignment(alignment)
    }
}

#Preview {
    CustomText(text: "Text", size: 24, bold: true, alignment: .center, color: .black)
}
