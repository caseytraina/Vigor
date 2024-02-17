//
//  VigorApp.swift
//  Vigor
//
//  Created by Casey Traina on 2/16/24.
//

import SwiftUI
import FirebaseCore
import FamilyControls
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    private var locationApi: LocationApi?
    var authModel = AuthViewModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        //FirebaseApp.configure()
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
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.string(from: timestamp)
                   
                   print("- Fetched Location: Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude) + \(formattedTimestamp)")
                let userId = self.authModel.user?.uid
                let documentPath = "users/XhH7j17q0nPuc7U307HW/scores/\(date)/gps/\(formattedTimestamp)"
                let db = Firestore.firestore()

                db.document(documentPath).setData([
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        completionHandler(.failed)
                    } else {
                        print("Document successfully written at \(documentPath)")
                        completionHandler(.newData)
                    }
                }

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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let center = AuthorizationCenter.shared
    
    @StateObject var authModel: AuthViewModel // This needs to be initialized properly

    init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            _authModel = StateObject(wrappedValue: appDelegate.authModel)
        } else {
            _authModel = StateObject(wrappedValue: AuthViewModel()) // Fallback initialization
        }
        FirebaseApp.configure()
    }
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
