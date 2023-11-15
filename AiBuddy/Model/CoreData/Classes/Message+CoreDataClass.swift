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
        setDefaults()
    }
    func setDefaults() {
        //set to random new UUID
        self.id = UUID()
        //set timestamp to date self was first initialized
        self.timestamp = Date()
    }
}
