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
    }
}
