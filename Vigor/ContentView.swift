//
//  ContentView.swift
//  Vigor
//
//  Created by Casey Traina on 2/16/24.
//

import SwiftUI
//import SwiftData

struct ContentView: View {

    
    
    
    
    @State var score: Int = 0
    
    var body: some View {
        
        
        NavigationLink(destination: ContentView2(), label: {
            Text("Go")
        })
        
        
    }

}



struct ContentView1: View {

    
    @Binding var score: Int
    
    var body: some View {
        
        VStack {
            Text("\(score)")
                .padding()
                
            Button(action: {
                score += 1
            }, label: {
                Text("Increase")
                    .foregroundStyle(.white)
            })
            .background(.black)
            .opacity(0.5)
            .padding()
            .cornerRadius(10)
            
            
        }

        
    }

}
struct ContentView2: View {
    @StateObject private var locModel = LocationApi.shared
    var body: some View {
        VStack {
            if let location = locModel.userLocation {
                Text("User location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            } else {
                Text("Waiting for location...")
            }
        }
        .onAppear {
            locModel.startLocationUpdates()
        }
    }
}
