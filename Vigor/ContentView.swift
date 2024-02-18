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
import SwiftUICharts

struct ContentView: View {
//    @StateObject var dataModel: DataViewModel = DataViewModel()
    @State var score_overall: Int = 30
    @State var score_trend: Int = 80

    @State var sheet = true
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.accentColor.ignoresSafeArea()
                VStack {
                    DateCarousel()
                        .frame(height: geo.size.height * 0.15)
                    Spacer()
                    OverlayHome()
                        .background(.white)
                        .clipShape(RoundedCorner(radius: 15, corners: [.topLeft, .topRight]))
                        .ignoresSafeArea()
                        .shadow(radius: 5, y: -2)

                }
            }
        }
    }
}


enum Page {
    case resources
    case warning
    case notebook
}

struct OverlayHome: View {
    
    var demoData: [Double] = [38, 54, 58, 74, 57, 75, 73]
    
    @State var sheet = false
    @State var pageClicked: Page = .resources
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack {

                    HStack {
                        Spacer()
                        Text("curo")
                            .foregroundStyle(Gradient(colors: [.accentColor, .orange]))
                            .font(Font.custom("CircularStd-Black", size: 32))
                            .multilineTextAlignment(.center)
                            .padding(.top)
                        Spacer()
                    }
                    .frame(width: geo.size.width * 0.95)
                    
                    VStack {
                        LineChartView(data: demoData, title: "Welcome Back, Filip", legend: "Week-to-date", form: ChartForm.extraLarge, dropShadow: false)
                            .padding(5)
                    }
                    .frame(width: geo.size.width * 0.95)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 5)
                    .shadow(radius: 1)

//                    Spacer()
                    
                    HStack {
                        ProgressCircle(progress: 1.5)
                            .frame(width: geo.size.width * 0.15)
                            .padding()
                        CustomText(text: "You're doing great. Try going on a walk today to increase your score even more!", size: 16, bold: false, alignment: .leading, color: .black)
                        Spacer()
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 15)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 1)
                            .brightness(0.25)
                    )
                    .frame(width: ChartForm.extraLarge.width, height: geo.size.width * 0.25)
                    .padding(.top)

                    HStack {
                        Button(action: {
                            pageClicked = .resources
                            sheet = true
                        }, label: {
                            ResourceTile()
                                .aspectRatio(1, contentMode: .fit)
                        })
                        Spacer()
                        Button(action: {
                            pageClicked = .warning
                            sheet = true
                        }, label: {
                            WarningTile()
                                .aspectRatio(1, contentMode: .fit)
                        })
                        Spacer()
                        Button(action: {
                            pageClicked = .notebook
                            sheet = true
                        }, label: {
                            NotebookTile()
                                .aspectRatio(2, contentMode: .fit)
                        })

                    }
                    .frame(width: ChartForm.extraLarge.width, height: geo.size.width * 0.2)
                    .padding(.top)


                    
                    Spacer()
                    
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            // Fill the available space
            .background(Color.white) // Specify a background color
            .sheet(isPresented: $sheet, content: {
                switch pageClicked {
                case .resources:
                    Text("Resources")
                case .warning:
                    Text("Warning")
                case .notebook:
                    Text("Notebook")

                }
            })
            
        }
    }
}


#Preview {
    ContentView()
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

