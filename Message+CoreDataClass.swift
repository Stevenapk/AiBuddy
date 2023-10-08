//
//  Message+CoreDataClass.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/8/23.
//
//

import Foundation
import CoreData

@objc(Message)
public class Message: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //set defaults
        //id
        self.id = UUID()
        //timestamp ("created on")
        self.timestamp = Date()
        
        //add the newest timestamp and the newest text content to character properties
        self.character.modified = timestamp
        self.character.lastText = content
        
//        addObserver(self, forKeyPath: "myProperty", options: .new, context: nil)
    }
    
    func updateCharacterValues() {
        self.character.modified = timestamp
        self.character.lastText = content
    }

//    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "myProperty" {
//            if let newValue = change?[.newKey] as? String {
//                handleMyPropertyChange(newValue)
//            }
//        }
//    }
//
//    func handleMyPropertyChange(_ newValue: String) {
//        print("myProperty changed to: \(newValue)")
//        // Add your custom logic here
//        self.character.modified = timestamp
//        self.character.lastText = content
//    }
//
//    deinit {
//        removeObserver(self, forKeyPath: "myProperty")
//    }
}
