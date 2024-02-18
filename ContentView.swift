//
//  ContentView.swift
//  Vigor
//
//  Created by Casey Traina on 2/16/24.
//

import SwiftUI
//import SwiftData
/*
struct ContentView: View {

    @StateObject var dataModel: DataViewModel = DataViewModel()

    
    
    @State var score: Int = 0
    
    var body: some View {
        
        
        Text("Hey")
        
    }

}
 */
/*
struct ContentView: View {

    @StateObject var dataModel: DataViewModel = DataViewModel()
    @State var score_overall: Int = 30
    @State var score_trend: Int = 80
    
    var body: some View {
        VStack {
            DateCarousel()
                .frame(height: 100) // Adjust the height as needed
            
            // Convert score to a CGFloat between 0 and 1
            
            
            ProgressBar(score: CGFloat(score_overall))
                            .frame(height: 20)
                            .padding() // Add padding for better visual spacing
            // Include the ProgressCircle here
            let progressValue = CGFloat(score_trend) / 100
            ProgressCircle(progress: progressValue)
                .frame(width: 200, height: 100) // Set the size of the ProgressCircle
            
           
        }
       
    }
}

*/
import SwiftUI

struct ContentView: View {
    @StateObject var dataModel: DataViewModel = DataViewModel()
    @State var score_overall: Int = 30
    @State var score_trend: Int = 80

    var body: some View {
        VStack {
            DateCarousel()
                .frame(height: 100) // Adjust the height as needed

            ProgressBar(score: CGFloat(score_overall))
                .frame(height: 20)
                .padding() // Add padding for better visual spacing
            
            let progressValue = CGFloat(score_trend) / 100
            ProgressCircle(progress: progressValue)
                .frame(width: 200, height: 100) // Set the size of the ProgressCircle

            // Include the OpenAIResponseView here
            OpenAIResponseView()
                .padding() // Add padding for better visual spacing
        }
    }
}
