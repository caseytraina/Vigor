//
//  WarningTile.swift
//  Vigor
//
//  Created by Casey Traina on 2/18/24.
//

import SwiftUI

struct WarningTile: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Image(systemName: "exclamationmark.bubble.fill")
                    .resizable()
                    .frame(width: geo.size.height * 0.5, height: geo.size.height * 0.5)
                    .foregroundStyle(.yellow)
                    .brightness(0.5)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct NotebookTile: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Image(systemName: "square.and.pencil.circle")
                    .resizable()
                    .frame(width: geo.size.height * 0.5, height: geo.size.height * 0.5)
                    .foregroundStyle(.gray)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
                    .brightness(0.25)
            )
        }
    }
}

struct ResourceTile: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Image(systemName: "phone")
                    .resizable()
                    .frame(width: geo.size.height * 0.5, height: geo.size.height * 0.5)
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
                    .brightness(0.25)
            )
        }
    }
}

struct QuestionTile: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Image(systemName: "questionmark.app.dashed")
                    .resizable()
                    .frame(width: geo.size.height * 0.5, height: geo.size.height * 0.5)
                    .foregroundStyle(Gradient(colors: [.blue, .purple]))
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
                    .brightness(0.25)
            )
        }
    }
}

#Preview {
    QuestionTile()
        .frame(width: 100, height: 100)
}
