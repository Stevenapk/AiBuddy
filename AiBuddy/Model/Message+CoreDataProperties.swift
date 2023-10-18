//
//  Message+CoreDataProperties.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/8/23.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var content: String
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var isSentByUser: Bool
    @NSManaged public var character: Character
    
    func set(_ character: Character) {
        //set character property
        self.character = character
        //update relevant properties on the now relationally-bound character
        self.character.modified = timestamp
        self.character.lastText = content
    }

}

extension Message : Identifiable {

}
