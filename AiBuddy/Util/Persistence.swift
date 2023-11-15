//
//  Persistence.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import CoreData
import Combine
import SwiftUI

struct PersistenceError: Identifiable {
    let id = UUID()
    let error: Error
}

class PersistenceController: ObservableObject {
    
    static let shared = PersistenceController()

    // A preview instance of `PersistenceController` for SwiftUI previews
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        return result
    }()

    // The CloudKit compatible Core Data container for AiBuddy
    let container: NSPersistentCloudKitContainer
    
    // Publish the persistent store error
    @Published var persistenceError: PersistenceError? = nil

    // MARK: - Initialization
    
    /// Initializes a new `PersistenceController`.
    /// - Parameter inMemory: A boolean indicating whether to use an in-memory store.
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "AiBuddy")
        
        // Configure the container for an in-memory store if specified
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Load persistent stores and handle completion
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error {
                self.persistenceError = PersistenceError(error: error)
            }
        })
        
        // Enable automatic merging of changes from the parent context
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                self.persistenceError = PersistenceError(error: error)
            }
        }
    }
}
