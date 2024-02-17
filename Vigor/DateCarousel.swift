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
    init() {
        dateFormatter.dateFormat = "EEEE"
    }

    var body: some View {
        HStack {
            TabView {
            ForEach(-weeksToShow..<weeksToShow, id: \.self) { weekNum in
                HStack {
                    Spacer()
                    ForEach(-3..<4, id: \.self) { i in
                        if let weekStartDate = Calendar.current.date(byAdding: .weekOfYear, value: weekNum, to: today) {

                                VStack {
                                    
                                    if let tomorrow = calendar.date(byAdding: .day, value: i, to: weekStartDate) {
                                        let day = calendar.component(.day, from: tomorrow)
                                        CustomText(text: "\(day)", size: 18, bold: (weekNum, i) == (0,0) ? true : false, alignment: .center, color: .white)
                                        if let char = dateFormatter.string(from: tomorrow).first {
                                            CustomText(text: "\(char)", size: 18, bold: (weekNum, i) == (0,0) ? true : false, alignment: .center, color: .white)
                                        }
                                    }
                                    
                                }
                            Spacer()
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            .tabViewStyle(PageTabViewStyle())

        }
        .background(Color.accentColor)
    }
}

#Preview {
    DateCarousel()
}
