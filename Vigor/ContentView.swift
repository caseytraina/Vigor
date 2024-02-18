//
//  ContentView.swift
//  Vigor
//
//  Created by Casey Traina on 2/16/24.
//

import SwiftUI
import SwiftUICharts
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ContentView: View {
    
    @StateObject var dataModel: DataViewModel = DataViewModel()
    @EnvironmentObject var authModel: AuthViewModel
    
    @State var currentDate = Date()
    
    @State var score_overall: Int = 30
    @State var score_trend: Int = 80

    @State var sheet = true
    
//    @State var score: Score = Score(depression: 0, comparison: 0)
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.accentColor.ignoresSafeArea()
                VStack {
                    DateCarousel(currentDate: $currentDate)
                        .frame(height: geo.size.height * 0.15)
                    Spacer()
                    OverlayHome(currentDate: $currentDate)
                        .background(.white)
                        .clipShape(RoundedCorner(radius: 15, corners: [.topLeft, .topRight]))
                        .ignoresSafeArea()
                        .shadow(radius: 5, y: -2)

                }
            }

        }
    }
    
    private func getScores() async {
        let db = Firestore.firestore()
        let date = IDformattedDate(date: currentDate)
        let path = db.collection("users").document("PRRRkOFxB3NLrvKTgRmC9gLzzzg2").collection("scores").document(date)
        
        do {
            let snap = try await path.getDocument()
            let score = try snap.data(as: Score.self)
            print(score)
//            self.score = score
        } catch {
            print("Error getting score: \(error)")
        }
        
    }


    // Assuming you have a Score struct that conforms to Codable
    struct Score: Codable {
        let comparison: Int
        let depression: Int
        // Include other properties that match your Firestore document structure
    }

}

struct Score: Codable {
  @DocumentID var id: String?
  var depression: Int
  var comparison: Int
}


enum Page {
    case resources
    case warning
    case notebook
}

struct OverlayHome: View {
    
    @EnvironmentObject var authModel: AuthViewModel
    @Binding var currentDate: Date
    @State var compScores: [Double] = []
    @State var scoresForTheWeek: [Score] = []
    @State var sheet = false
    @State var pageClicked: Page = .resources
    
    @State var depressionScore = 50
    
    @State var text = "Today, I'm feeling..."
    
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
                        LineChartView(data: compScores.reversed(), title: "Welcome Back, \(authModel.current_user?.firstName ?? "Friend")", legend: "Week-to-date (\(formattedDate(date: currentDate)))", form: ChartForm.extraLarge, dropShadow: false)
                            .padding(5)
                    }
                    .frame(width: geo.size.width * 0.95)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 5)
                    .shadow(radius: 1)

//                    Spacer()
                    
                    HStack {
                        ProgressCircle(progress: $depressionScore)
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
                ZStack {
                    if pageClicked == .notebook {
                        Color.accentColor.ignoresSafeArea()
                    }
                    VStack {
                        switch pageClicked {
                        case .resources:
                            Resources()
                        case .warning:
                            Warning()
                        case .notebook:
                            Notebook(text: $text, currentDate: $currentDate)
                        }
                    }
                }
                .presentationDetents([.medium])

            })
            .onChange(of: sheet) { newSheet in
                if !newSheet {
                    Task {
                        await authModel.updateText(date: Date(), text: text)
                    }
                }
            }
            .onAppear {
                Task {
                    await self.getScoresForLastWeek()
                }
            }
            .onChange(of: currentDate) { _ in
                Task {
                    await self.getScoresForLastWeek()
                }
            }
            
        }
    }
    private func getScoresForLastWeek() async {
        let db = Firestore.firestore()
        var scoresForTheWeek: [Score] = []
        self.scoresForTheWeek = []
        for dayOffset in 0..<7 {
            // Calculate the date for the day we are fetching the score
            guard let dateForScore = Calendar.current.date(byAdding: .day, value: -dayOffset, to: currentDate) else {
                continue
            }
            
            // Format the date to match the document ID format in Firestore
            let dateID = IDformattedDate(date: dateForScore)
            
            // Define the path to the document for that day
            let path = db.collection("users").document(authModel.user?.uid ?? "").collection("scores").document(dateID)
            
            do {
                // Attempt to fetch the document for the specific day
                let snap = try await path.getDocument()
                let score = try snap.data(as: Score.self)
                scoresForTheWeek.append(score)
                compScores.append(Double(score.comparison))
            } catch {
                print("Error getting score for \(dateID): \(error)")
            }
        }
        depressionScore = scoresForTheWeek[0].depression
        // After the loop, you have an array of scores for the week
        // You can now use scoresForTheWeek as needed in your app
        print(scoresForTheWeek)
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


struct Notebook: View {
    
    @Binding var text: String
    @Binding var currentDate: Date
    var body: some View {
        VStack {
            HStack {
                CustomText(text: formattedDate(date: currentDate), size: 24, bold: true, alignment: .leading, color: .white)
                    .padding()
                Spacer()
            }
            .frame(width: screenSize.width * 0.95)

            TextEditor(text: $text)
                .font(Font.custom("CircularStd-Book", size: 18))
                .multilineTextAlignment(.leading)
                .padding(.top)
                .frame(width: screenSize.width * 0.95, height: screenSize.height * 0.3)
                .cornerRadius(10)
                
        }
    }
    
}


struct Warning: View {
    
    
    var body: some View {
        VStack {
            HStack {
                WarningTile()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: screenSize.width * 0.2)
                Spacer()
            }
            .frame(width: screenSize.width * 0.95)
            .padding()

            VStack(alignment: .leading) {
                CustomText(text: "You have been exhibiting higher than normal rates of tendencies that leave you at risk of developing depression", size: 18, bold: true, alignment: .leading, color: .black)
                    .padding(.bottom, 10)
                CustomText(text: "If you think you are in need of it, seek help in our resource section.", size: 18, bold: true, alignment: .leading, color: .black)
            }
            .padding()
            .frame(width: screenSize.width * 0.95)
            .foregroundStyle(.white)
            .background(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
                    .brightness(0.25)
            )

            Spacer()

                
        }
    }
    
}

struct Resources: View {
    var body: some View {
        Form {
            Section(header: CustomText(text: "Proffesional Help Resources", size: 18, bold: false, alignment: .center, color: .black)
                .padding(.top)) {
                    Text("Emergency Help Line Number: \n 988")
                    Text("SAMHSA National Help Line: 1-800-662-4357")
                    
                }
            Section(header: CustomText(text: "Self-Help Resources", size: 18, bold: false, alignment: .center, color: .black)
                .padding(.top)) {
                    Text("Online Therapist Finder: betterhelp.com")
                    Text("Mindfulness Guided Meditation App: Headspace")
                }
            
        }
    }
}


extension Int {
    var ordinalSuffix: String {
        let ones = self % 10
        let tens = (self / 10) % 10
        if tens == 1 {
            return "th"
        }
        switch ones {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
}

func formattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM"
    
    let day = Calendar.current.component(.day, from: date)
    let year = Calendar.current.component(.year, from: date)
    
    return "\(dateFormatter.string(from: date)) \(day)\(day.ordinalSuffix), \(year)"
}

func IDformattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let day = Calendar.current.component(.day, from: date)
    let year = Calendar.current.component(.year, from: date)
    
    return dateFormatter.string(from: date)
}

