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

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        return result
    }()

    let container: NSPersistentCloudKitContainer
    
    @Published var persistenceError: PersistenceError? = nil // Publish the persistent store error

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "AiBuddy")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error {
                self.persistenceError = PersistenceError(error: error)
                // Replace this implementation with code to handle the error appropriately.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
            }
        })
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
