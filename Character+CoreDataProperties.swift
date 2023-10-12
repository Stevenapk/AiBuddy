//
//  Character+CoreDataProperties.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/8/23.
//
//

import Foundation
import CoreData
import SwiftUI


extension Character {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var name: String
    @NSManaged public var isRecognizableName: Bool
    @NSManaged public var promptPrefix: String
    @NSManaged public var id: UUID
    @NSManaged public var modified: Date
    @NSManaged public var lastText: String
    @NSManaged public var messages: NSSet?
    
    var image: UIImage? {
        return nil
    }
    
    var sortedMessages: [Message] {
        if let messages {
            let unsortedMessageArray = messages.allObjects as! [Message]
            return unsortedMessageArray.sorted { $0.timestamp < $1.timestamp }
        }
        return []
    }
    
//    func promptFrom(_ messageText: String) -> String {
//
//        let humanifyAI = "When I ask you questions, ask me a question back, if I just answered your question, comment on it and mirror what I said in a way that makes me feel heard and listened to. It should feel like I'm texting a real person, unless I tell you you are something besides a person."
//
//        let formattedPrompt = "Act as \(promptPrefix). \(humanifyAI) \(messageText)"
//
//        return formattedPrompt
//    }
    
    func promptFrom(_ messageText: String) -> String {
        
//        let humanifyAI = "When I ask you questions, ask me a question back, if I just answered your question, comment on it and mirror what I said in a way that makes me feel heard and listened to. It should feel like I'm texting a real person, unless I tell you you are something besides a person"
        
        let humanifyAI = ""
        
        var formattedPrompt = ""
        
        if isRecognizableName {
            if !promptPrefix.isEmpty {
                formattedPrompt = "Act as \(name). Additionally, you are \(promptPrefix). \(humanifyAI). \(messageText)."
            } else {
                formattedPrompt = "Act as \(name). \(humanifyAI). \(messageText)"
            }
        } else {
            if !promptPrefix.isEmpty {
                formattedPrompt = "Act as \(promptPrefix). \(humanifyAI). if I ask, your name is \(name). \(messageText)."
            } else {
                //TODO: should not be allowed to do only a name if isRecognizableName is set to false, so if the switch is set to false, the word "optional" in parenthesis should be replaced with "REQUIRED". You will also need an info button next to this switch so they know exactly what it does. The words should be "Well-known person or character" right next to the character, the info button will say, "If it is a well-known person or character such as Selena Gomez or Peter Pan, the about me section is no longer required. Although you may still use it to add aspects to their personality, character, or life story.
                formattedPrompt = "\(humanifyAI). if I ask, your name is \(name). \(messageText)."
            }
        }
        
        return formattedPrompt
    }

    
    var firstInitial: String {
        String(name.prefix(1)).uppercased()
    }
    
    //used for profile icon background color selection
    var colorForFirstInitial: Color {
        switch firstInitial.lowercased() {
        case "a", "b", "c", "d":
            return Color(hue: 0.1, saturation: 1.0, brightness: 0.8)
        case "e", "f", "g", "h":
            return Color(hue: 0.3, saturation: 1.0, brightness: 0.75)
        case "i", "j", "k", "l":
            return Color(hue: 0.5, saturation: 1.0, brightness: 0.75)
        case "m", "n", "o", "p":
            return Color(hue: 0.7, saturation: 1.0, brightness: 0.75)
        case "q", "r", "s", "t":
            return Color(hue: 0.99, saturation: 1.0, brightness: 0.75)
        case "u", "v", "w":
            return Color(hue: 0.75, saturation: 0.5, brightness: 0.75)
        case "x", "y", "z":
            return Color(hue: 0.0, saturation: 0.0, brightness: 0.3)
        default:
            return Color.black
        }
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
