//
//  GPTtextbox.swift
//  Vigor
//
//  Created by Filip Henriksson on 17.02.24.
//

import Foundation
import SwiftUI

struct OpenAIResponseView: View {
    @State private var openAIResponse: String = "Loading response..."

    var body: some View {
        VStack {
            Text("OpenAI Response:")
                .font(.headline)
                .padding()

            TextEditor(text: $openAIResponse)
                .frame(height: 200)
                .padding()
                .border(Color.gray, width: 1)
                .cornerRadius(5)
        }
        .onAppear {
            fetchOpenAIResponse { response in
                DispatchQueue.main.async {
                    self.openAIResponse = response
                }
            }
        }
    }
}
