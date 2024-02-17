//
//  LocationApi.swift
//  Vigor
//
//  Created by Clayton Moore on 2/17/24.
//

import Foundation
import CoreLocation
import Firebase



@MainActor
class LocationApi: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationApi()  // Singleton instance
    private var locationManager: CLLocationManager?
    @Published var userLocation: CLLocation?
    private var locationFetchCompletionHandler: ((CLLocation?, Date?, Error?) -> Void)?

    override private init() {  // Make init private to prevent outside instances
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.requestWhenInUseAuthorization() // Consider using requestAlwaysAuthorization() if your app needs background location updates
    }
    
    func startLocationUpdates() {
        locationManager?.startUpdatingLocation()
    }
    
    func fetchCurrentLocation(completion: @escaping (CLLocation?, Date?, Error?) -> Void) {
        self.locationFetchCompletionHandler = completion
        locationManager?.requestLocation() // Request a single update on the user's location
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
            let timestamp = Date() // Capture the current time
            DispatchQueue.main.async {
                self.userLocation = location
                self.locationFetchCompletionHandler?(location, timestamp, nil)
                self.locationFetchCompletionHandler = nil // Reset the completion handler
            }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
        nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            let timestamp = Date() // Capture the current time of failure
            DispatchQueue.main.async {
                self.locationFetchCompletionHandler?(nil, timestamp, error)
                self.locationFetchCompletionHandler = nil // Reset the completion handler after handling error
            }
        }
    }
}
