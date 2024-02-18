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
                
                let userData = [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude
                    ]
                print(userData)
                let db = Firestore.firestore();

                // Assuming you have these values already
                let userId = "PRRRkOFxB3NLrvKTgRmC9gLzzzg2"
                
                let longitude = location.coordinate.longitude;
                let latitude = location.coordinate.latitude;

                // Path to add the new document
                let gpsRef = db.collection("users").document(userId)
                    .collection("scores").document(date)
                                .collection("gps").document(formattedTimestamp);

                // Adding the location data
                let geo = GeoPoint(latitude: latitude, longitude: longitude)
                let time = Timestamp(date: Date())
                
                gpsRef.setData([
                    "location": geo,
                    "timestamp": time
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                // the path is collection of users/then document userId/ collection scores / document date /collection gps/ and within this I want to add a timestamp document which within it is a location - long, latitude
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
}
