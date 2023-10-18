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
//    static let ad = UIApplication.shared.delegate as! AppDelegate
//    static let context = ad.persistentContainer.viewContext
    lazy var persistentContainer: NSPersistentCloudKitContainer = PersistenceController.shared.container
    static let context = PersistenceController.shared.container.viewContext
}
