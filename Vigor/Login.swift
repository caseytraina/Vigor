//
//  Login.swift
//  Vigor
//
//  Created by Casey Traina on 2/18/24.
//

import SwiftUI

struct Login: View {
    
    @EnvironmentObject var authModel: AuthViewModel
    
    @State var email = ""
    @State var password = ""
    
    @State var active = false
    var body: some View {
        
        Spacer()
        
        Text("curo")
            .foregroundStyle(Gradient(colors: [.accentColor, .orange]))
            .font(Font.custom("CircularStd-Black", size: 64))
            .multilineTextAlignment(.center)
            .padding()
        
        Spacer()
        
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
                    try await authModel.signIn(email: email, password: password)
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
        .disabled(password.isEmpty || email.isEmpty)    }
}

#Preview {
    Login()
}
