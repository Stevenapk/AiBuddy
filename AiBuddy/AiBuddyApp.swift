//
//  AiBuddyApp.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import CoreData
import CloudKit
#if !TEST_TARGET
import FirebaseCore
#endif

@main
struct AiBuddyApp: App {
    
    let persistenceController = PersistenceController.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // Present ContentView with the Persistence Controller instance and view context added to environment
            return ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(PersistenceController.shared)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = PersistenceController.shared.container

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
}
