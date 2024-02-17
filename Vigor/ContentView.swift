//
//  ContentView.swift
//  Vigor
//
//  Created by Casey Traina on 2/16/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @StateObject var dataModel: DataViewModel = DataViewModel()
    
    
    
    @State var score: Int = 0
    
    var body: some View {
        
        
        Text("Hey")

        
    }

}

#Preview {
    ContentView()
}

