//
//  OnboardingFlow.swift
//  Vigor
//
//  Created by Filip Henriksson on 17.02.24.
//

import Foundation

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Image("IMG_ONBOARD_1") // Reference from Assets
                .resizable()
                .scaledToFit()
                .frame(height: 410)
                .clipped()
            
            CustomText(text: "Welcome to CURA", size: 35, bold: true, alignment: .center, color: .black)
            //Text("Welcome to VIGOR")
                .font(.largeTitle)
               // .fontWeight(.bold)
            
            CustomText(text: "Supporting your mental health journey.", size: 18, bold: false, alignment: .center, color: .black)
                .font(.headline)
                .padding()

            Spacer()

            NavigationLink(destination: PrivacyConsentView()) {
                CustomText(text: "Get Started", size: 18, bold: false, alignment: .center, color: .black)
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(25)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top)
    }
}







struct PrivacyConsentView: View {
    @State private var agreeToTerms = false

    var body: some View {
        VStack {
            Image("IMG_ONBOARD_2") // Reference from Assets
                .resizable()
                .scaledToFit()
                .frame(height: 410)
                .clipped()
            
            ScrollView {
                CustomText(text: "Your Privacy & Consent", size: 18, bold: false, alignment: .center, color: .black)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                CustomText(text: "We respect your privacy and will only use your data to improve your experience. By agreeing, you consent to our data handling practices.", size: 18, bold: false, alignment: .center, color: .black)
                    .padding()
            }
            
            Toggle(isOn: $agreeToTerms) {
                CustomText(text: "I agree to the Privacy Policy", size: 14, bold: false, alignment: .center, color: .black)
                
            }
            .padding()
            
            if agreeToTerms {
                NavigationLink(destination: AccountCreationView()) {
                    CustomText(text: "Agree & Continue", size: 18, bold: false, alignment: .center, color: .black)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(25)
                }
                .padding()
            }
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.top)
    }
}


struct AccountCreationView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    
    var body: some View {
        VStack {
            Image("IMG_ONBOARD_3") // Reference from Assets
                .resizable()
                .scaledToFit()
                //.frame(height: 410) // Consider adjusting or removing this fixed height
                .clipped()
            
            Form {
                Section(header: CustomText(text: "Create Your Account", size: 14, bold: false, alignment: .center, color: .black)
                    .padding(.top)) {
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
            }
            
            NavigationLink(destination: ContentView()) {
                CustomText(text: "Next", size: 18, bold: false, alignment: .center, color: .black)
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(25)
            }
            .padding()
            .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty)
            // .edgesIgnoringSafeArea(.top) // Consider removing or adjusting this for the current view
        }
    }
}
