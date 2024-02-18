//
//  OnboardingFlow.swift
//  Vigor
//
//  Created by Filip Henriksson on 17.02.24.
//

import Foundation

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var authModel: AuthViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Image("IMG_ONBOARD_1") // Reference from Assets
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenSize.width)
                    .ignoresSafeArea()
                    .clipShape(Circle())
                    .offset(x: screenSize.width / 2, y: -screenSize.height / 3)
                Spacer()
            }

            VStack {
                
                Spacer()

                HStack {
                    Text("curo")
                        .foregroundStyle(Gradient(colors: [.accentColor, .red]))
                        .font(Font.custom("CircularStd-Black", size: 64))
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                
                HStack {
                    CustomText(text: "Supporting your mental health journey.", size: 18, bold: true, alignment: .center, color: .black)
                        .font(.headline)
                        .padding()
                    Spacer()
                }
                
                Spacer()
                
                NavigationLink(destination: PrivacyConsentView().environmentObject(authModel)) {
                    CustomText(text: "Get Started", size: 18, bold: true, alignment: .center, color: .white)
                        .padding()
                        .frame(width: screenSize.width * 0.85)

                        .background(.accent)
                        .clipShape(Capsule())

//                        .cornerRadius(25)
                    
                }
                
                NavigationLink(destination: Login().environmentObject(authModel)) {
                    CustomText(text: "Already have an account? Sign in", size: 18, bold: true, alignment: .center, color: .accent)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                
                
                .padding()
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}






struct PrivacyConsentView: View {
    
    @EnvironmentObject var authModel: AuthViewModel

    
    @State private var agreeToTerms = false

    var body: some View {
        
        ZStack {
                VStack {
                    Image("IMG_ONBOARD_2") // Reference from Assets
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenSize.width)
                        .ignoresSafeArea()
                        .clipShape(Circle())
                        .offset(x: screenSize.width / 2, y: -screenSize.height / 3)
                    Spacer()
                }
            
            VStack {
                
                Spacer(minLength: screenSize.height / 2)
                VStack {
                    CustomText(text: "Your Privacy & Consent", size: 18, bold: false, alignment: .center, color: .black)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    CustomText(text: "We respect your privacy and will only use your data to improve your experience. By agreeing, you consent to our data handling practices.", size: 18, bold: false, alignment: .center, color: .black)
                        .padding()
                }
                
                Spacer()
                
                Toggle(isOn: $agreeToTerms) {
                    CustomText(text: "I agree to the Privacy Policy", size: 14, bold: false, alignment: .center, color: .black)
                    
                }
                .padding()
                
                NavigationLink(destination: AccountCreationView().environmentObject(authModel)) {
                        CustomText(text: "Agree & Continue", size: 18, bold: false, alignment: .center, color: .black)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(.accent)
                            .cornerRadius(25)
                    }
                    .padding()
                    .disabled(!agreeToTerms)
                
            }
            .edgesIgnoringSafeArea(.top)
            
        }
    }
}


struct AccountCreationView: View {
    
    @EnvironmentObject var authModel: AuthViewModel

    
    @State private var firstName = ""
    @State private var password = ""
    @State private var email = ""
    
    
    @State var active = false
    
    var body: some View {
        
        ZStack {
            
            VStack {
                Image("IMG_ONBOARD_3") // Reference from Assets
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenSize.width)
                    .ignoresSafeArea()
                    .clipShape(Circle())
                    .offset(x: screenSize.width / 2, y: -screenSize.height / 3)
                Spacer()
            }
            
            
            VStack {
                
                Spacer()
                
                HStack {
                    CustomText(text: "One last step", size: 32, bold: true, alignment: .leading, color: .black)
                        .padding()
                    Spacer()
                }
                
                
                Spacer()
                
                
                TextField("First Name", text: $firstName)
                    .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "settings")))
                    .frame(width: screenSize.width * 0.9)
                    .padding(.top, 5)
                TextField("Email", text: $email)
                    .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "settings")))
                    .frame(width: screenSize.width * 0.9)
                    .padding(.top, 5)
                SecureField("Password", text: $password)
                    .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "settings")))
                    .frame(width: screenSize.width * 0.9)
                    .padding(.top, 5)

                
                
                NavigationLink(
                    destination: ContentView().environmentObject(authModel),
                    isActive: $active,
                    label: {
                        EmptyView()
                    })
                
                
                Button(action: {
                    Task {
                        do {
                            try await authModel.createAccount(email: email, password: password)
                            await authModel.createUserInFirestore(firstName: firstName, lastName: "", email: email)
                            active = true
                        } catch {
                            print("There was an error creating: \(error)")
                        }
                    }
                }, label: {
                    CustomText(text: "Finish", size: 18, bold: false, alignment: .center, color: .black)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.accent)
                        .cornerRadius(25)
                })
                .padding()
                .disabled(firstName.isEmpty || password.isEmpty || email.isEmpty)
            }
        }
    }
}
