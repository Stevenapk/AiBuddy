//
//  Character+CoreDataProperties.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/8/23.
//
//

import Foundation
import CoreData


extension Character {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var name: String
    @NSManaged public var promptPrefix: String
    @NSManaged public var id: UUID
    @NSManaged public var modified: Date
    @NSManaged public var lastText: String
    @NSManaged public var messages: NSSet?
    
    var sortedMessages: [Message] {
        if let messages {
            let unsortedMessageArray = messages.allObjects as! [Message]
            return unsortedMessageArray.sorted { $0.timestamp < $1.timestamp }
        }
        return []
    }

}

// MARK: Generated accessors for messages
extension Character {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension Character : Identifiable {

}
