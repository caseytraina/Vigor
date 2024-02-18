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
    private var locationApi: LocationApi?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Your code to initiate a background fetch and update the UI with the fetched data
     //   let locationApi = LocationApi() // You may want to use a shared instance or dependency injection
       
        LocationApi.shared.fetchCurrentLocation { location, timestamp, error in
            if let location = location, let timestamp = timestamp {
                   let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                   let formattedTimestamp = dateFormatter.string(from: timestamp)
                   
                   print("- Fetched Location: Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude) + \(formattedTimestamp)")
                completionHandler(.newData)
            } else if let error = error {
                // Handle any errors
                print(error.localizedDescription)
                completionHandler(.failed)
            } else {
                completionHandler(.noData)
            }
        }
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
        WelcomeView()
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
