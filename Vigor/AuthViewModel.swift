//
//  AuthViewModel.swift
//  Vigor
//
//  Created by Casey Traina on 2/17/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class AuthViewModel: ObservableObject {
    
    var onChange: (() -> Void)?

    @Published var user: User?
    
    @Published var isLoggedIn = false
    
    @Published var error: Error?
    
    @Published var current_user: Profile?

    
    
    init() {
        listenToAuthState()
    }

    // This function listens for a change in the state of authentication, provided by Firebase docs. Upon a change, this initializes
    // the view model.
    func listenToAuthState() {
        
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            DispatchQueue.main.async {
                if let user {
                    self?.user = user

                    Task { [self] in
                        await self?.configureUser(self?.user?.uid ?? "")
                        self?.isLoggedIn = true
                    }

                } else {
                    self?.user = nil
                    self?.isLoggedIn = false
                }
            }
        }
    }
    
    func updateText(date: Date, text: String) async {
        let db = Firestore.firestore()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let utcDate = dateFormatter.string(from: date)
        
        do {
            if let uid = self.user?.uid {
                let path = db.collection("users").document(uid).collection("journal").document(utcDate)
                try await path.setData([
                    "entry" : text
                ])
            }
        } catch {
            print("There was an error updating the text: \(error)")
        }
        
        
    }
    
    // email-based account creation. No longer in use.
        func createAccount(email: String, password: String) async throws {

            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
                await configureUser(self.user?.uid ?? "")
            } catch {
                self.error = error
                throw error
            }
        }
    
    // text-message verification code for 2FA
    func sendCodeTo(_ phone: String) async {
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
              if let error = error {
                print("Error validating phone number: \(error)")
                return
              }
              // Code Sent
              UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
          }
    }

    enum PhoneSignInResult {
        case createdAccount
        case loggedIn
        case error
    }

    // Verification of phone number and verification code combination. Phone number-based sign in function.
    func signInPhone(code: String, completion: @escaping (PhoneSignInResult?) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            completion(nil)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error verifying number: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let isNewUser = authResult?.additionalUserInfo?.isNewUser {
                
                completion(isNewUser ? PhoneSignInResult.createdAccount : PhoneSignInResult.loggedIn)
                return
            }

            // If there's no error but we can't determine if user is new or existing
            completion(.createdAccount)
        }
    }
    
    func accountExists(credential: String) async -> Bool {
        do {
            if try await Firestore.firestore().collection("users").whereField("phoneNumber", isEqualTo: credential).getDocuments().isEmpty {
                return false
            } else {
                return true
            }
        } catch {
            print("error validating account: \(error)")
            return false
        }
    }


    // sign out function
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
        } catch {
            self.error = error
            throw error
        }
    }

    // This function adds or updates the user information housed in Firebase database.
    func createUserInFirestore(firstName: String, lastName: String, email: String) async {
        
        let db = Firestore.firestore()
        
        do {

            // Merging data in case you want to add or update more fields in future
            var data: [String: Any] = ["email" : email,
                                       "firstName" : firstName,
                                       "lastName" : lastName]

            // Upload data
            if let uid = self.user?.uid {
                try await db.collection("users").document(uid).setData(data, merge: true)
                print("User info saved successfully.")
            } else {
                print("No User detected.")

            }
            await self.configureUser("")
        } catch {
            print("Failed to save user info: \(error.localizedDescription)")
        }
    }
    
    // This function initializes the view model by declaring the account path in Firebase and retrieving the account info.
    @MainActor
    func configureUser(_ path: String) async {
        if let credential = self.user?.uid {
            let db = Firestore.firestore()
            let storageRef = db.collection("users").document(credential)
            
            do {
                self.current_user = try await fetchProfile(docRef: storageRef)
            } catch {
                print("error getting user: \(error)")
            }
        }
    }

    
    // email/password sign-in function
        func signIn(email: String, password: String) async throws {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                await configureUser("")
            } catch {
                self.error = error
                throw error
            }
        }

    // This function retrieves and returns the user profile from firebase, given a database path input. This returns type "Profile"
    func fetchProfile(docRef: DocumentReference) async throws -> Profile {
        do {
            let documentSnapshot = try await docRef.getDocument()
            let data = documentSnapshot.data()

            
            let profile = Profile(id: self.user?.uid ?? "",
                                  firstName: data?["firstName"] as? String ?? "",
                                  lastName: data?["lastName"] as? String ?? "",
                                  phoneNumber: data?["phoneNumber"] as? String ?? "")
            return profile
        } catch let error {
            print("Error fetching profile data: \(error)")
            throw error
        }
    }

}
