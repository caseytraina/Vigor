//
//  DateCarousel.swift
//  Vigor
//
//  Created by Casey Traina on 2/17/24.
//

import SwiftUI

struct DateCarousel: View {
    
    let today = Date()
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    let weeksToShow = 16
    
    @State var selectedDay = 0
    @State var selectedWeek = 0

    @Binding var currentDate: Date
    init(currentDate: Binding<Date>) {
        dateFormatter.dateFormat = "EEEE"
        self._currentDate = currentDate
    }

    var body: some View {
        HStack {
            TabView {
            ForEach(-weeksToShow..<weeksToShow, id: \.self) { weekNum in
                HStack {
                    Spacer()
                    ForEach(-3..<4, id: \.self) { i in
                        if let weekStartDate = Calendar.current.date(byAdding: .weekOfYear, value: weekNum, to: today) {

                            
                            Button(action: {
                                
                                selectedDay = i
                                selectedWeek = weekNum
                                
                            }, label: {
                                
                            
                                VStack {
                                    
                                    if let tomorrow = calendar.date(byAdding: .day, value: i, to: weekStartDate) {
                                        let day = calendar.component(.day, from: tomorrow)
                                        CustomText(text: "\(day)", size: 18, bold: (i == 0) ? true : false, alignment: .center, color: .white)
                                            .padding(5)
                                            .background(Circle().stroke(lineWidth: 2).fill((i,weekNum) == (selectedDay, selectedWeek) ? .white : .clear))
                                        if let char = dateFormatter.string(from: tomorrow).first {
                                            CustomText(text: "\(char)", size: 18, bold: (i == 0) ? true : false, alignment: .center, color: .white)
                                        }
                                    }
                                    
                                }
                                
                            })

                            Spacer()
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

        }
        .onChange(of: selectedDay) { newDay in
            
            if let newDate = Calendar.current.date(byAdding: DateComponents(day: newDay, weekOfYear: selectedWeek), to: Date()) {
                
                currentDate = newDate
            }
            
        }
        .onChange(of: selectedWeek) { newWeek in
            
            if let newDate = Calendar.current.date(byAdding: DateComponents(day: selectedDay, weekOfYear: newWeek), to: Date()) {
                
                currentDate = newDate
            }
            
        }
        .background(Color.accentColor)
    }
}

//#Preview {
//    DateCarousel()
//        .frame(height: screenSize.height * 0.1)
//}
