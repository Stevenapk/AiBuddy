//
//  File.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/8/23.
//

import Foundation
import SwiftUI
import CoreData

class Constants {
    // CloudKit / Core Data Persistent Container
    lazy var persistentContainer: NSPersistentCloudKitContainer = PersistenceController.shared.container
    // Core Data Context
    static let context = PersistenceController.shared.container.viewContext
}
