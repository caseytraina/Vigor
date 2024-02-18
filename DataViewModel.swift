//
//  DataViewModel.swift
//  Vigor
//
//  Created by Casey Traina on 2/17/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import DeviceActivity


@MainActor

class DataViewModel: ObservableObject {
    
    private var healthStore = HKHealthStore()
    @Published var totalSleepTimeInBed: String? = nil
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            self.totalSleepTimeInBed = "HealthKit is not available."
            return
        }
        
        // Define the types you want to read from HealthKit
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let typesToRead: Set<HKObjectType> = [sleepType]
        
        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.totalSleepTimeInBed = "Authorization error: \(error.localizedDescription)"
                    return
                }
                
                if success {
                    // Authorization request was successful, you can proceed to request sleep data
                    self?.requestSleepData()
                } else {
                    // Handle the case where the user denies authorization
                    self?.totalSleepTimeInBed = "Authorization was denied."
                }
            }
        }
    }
    
    func requestSleepData() {
        // Existing implementation of requestSleepData()
    }
    
    private func getDocument(_ path: DocumentReference) async -> [String : Any]? {
        do {
            let snapshot = try await path.getDocument()
            let data = snapshot.data()
            return data
        } catch {
            print("There was an error querying: \(error)")
        }
        return nil
    }

        
}

import Foundation
import HealthKit

class SleepDataAPI: ObservableObject {

    init() {
    }
    

    

}
