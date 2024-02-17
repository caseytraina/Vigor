//
//  VigorApp.swift
//  Vigor
//
//  Created by Casey Traina on 2/16/24.
//

import SwiftUI
import FirebaseCore
import FamilyControls

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct Vigor: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let center = AuthorizationCenter.shared


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
              .onAppear {
                  Task {
                      do {
                          try await center.requestAuthorization(for: .individual)
                      } catch {
                          print("Failed to enroll with error: \(error)")
                      }
                  }
              }
      }
    }
  }
}
