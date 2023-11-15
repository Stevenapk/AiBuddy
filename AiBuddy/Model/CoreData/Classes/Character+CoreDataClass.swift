//
//  Character+CoreDataClass.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/8/23.
//
//

import Foundation
import CoreData

@objc(Character)
public class Character: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setDefaults()
    }
    func setDefaults() {
        //set to random new UUID
        self.id = UUID()
        //set modified to date self was first initialized
        self.modified = Date()
    }
}
