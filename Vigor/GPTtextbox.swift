//
//  GPTtextbox.swift
//  Vigor
//
//  Created by Filip Henriksson on 17.02.24.
//

import Foundation
import SwiftUI

// OpenAIResponseFetcher.swift
class OpenAIResponseFetcher: ObservableObject {
    @Published var response: String = "Fetching response..."
    
    func fetchResponse() {
        //score = fetch it from database
        
        fetchOpenAIResponse(score: 80) { [weak self] result in
            DispatchQueue.main.async {
                self?.response = result
            }
        }
    }
}

// ContentView.swift
struct GPTContent: View {
    @StateObject private var fetcher = OpenAIResponseFetcher()

    var body: some View {
        CustomText(text: fetcher.response, size: 14, bold: false, alignment: .leading, color: .black)
            .lineLimit(3)
            .onAppear {
                fetcher.fetchResponse()
            }
    }
}

