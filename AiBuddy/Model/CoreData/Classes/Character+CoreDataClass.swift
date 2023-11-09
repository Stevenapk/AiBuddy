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
        self.id = UUID()
        self.modified = Date()
    }
}
