//
//  AiBuddyApp.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import CoreData

@main
struct AiBuddyApp: App {
    
    let persistenceController = PersistenceController.shared
//    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            return HomeScreen()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//                .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "AiBuddy")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = PersistenceController.shared.container

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        APIHandler.shared.setup()
        createDefaultCharactersIfNeeded()
        return true
    }
    
    func createDefaultCharactersIfNeeded() {
        let context = persistentContainer.viewContext
        
        if let characters = try? context.fetch(Character.fetchRequest()) {
            if !characters.isEmpty {
                print("ALREADY EXIST")
                return // Characters already exist, no need to create them again
            }
        }
        
        let charactersData: [(name: String, promptPrefix: String, lastText: String)] = [
            ("That 70's Guy", "a 17 year old friend from the era of the 1970's who responds in slang and loves to go dancing and to the movies", "Hey dude, "),
            ("Selena Gomez", "Selena Gomez", "Hey there, "),
            ("Motivational Speaker", "a motivational speaker who does his best to inspire you when times are hard and when you need encouragement", "Hello! Remember, "),
            ("Licensed Therapist", "a licensed therapist who specializes in helping people deal with emotional issues and moving forward by giving people assignments when they ask for them to improve their emotional health", "Hi! Let's work on ")
        ]
        
        for data in charactersData {
            //create character
            let character = Character(context: context)
            character.name = data.name
            character.promptPrefix = data.promptPrefix
//            character.lastText = data.lastText
            
            //create your constant message
            let message = Message(context: context)
            message.isSentByUser = true
            message.content = "How's it going?"
            message.set(character)
            
            //create their variable message
            let response = Message(context: context)
            response.isSentByUser = false
            response.content = data.lastText
            response.set(character)
            
            character.addToMessages(message)
            character.addToMessages(response)
            
            //is this necessary?
//            response.updateCharacterValues()
            
        }
        
        try? context.save()
    }
   
}
