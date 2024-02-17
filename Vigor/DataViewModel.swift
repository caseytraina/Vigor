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
    
    init() {
        
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
