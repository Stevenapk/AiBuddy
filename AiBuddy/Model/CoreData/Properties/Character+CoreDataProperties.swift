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
    @NSManaged public var imageData: ImageData?
    @NSManaged public var hasUnreadMessage: Bool
    
    // MARK: Computed Properties
    
    var imgData: Data? {
        return imageData?.imageData
    }
    
    var image: UIImage? {
        if let imgData {
            return UIImage(data: imgData)
        }
        return nil
    }
    
    var sortedMessages: [Message] {
        if let messages {
            guard let unsortedMessageArray = messages.allObjects as? [Message] else { return [] }
            return unsortedMessageArray.sorted { $0.timestamp < $1.timestamp }
        }
        return []
    }
    
    var sytemInfoForAI: String {
        if isRecognizableName {
            if !promptPrefix.isEmpty {
                return "Act as \(name). Additionally, you are \(promptPrefix)."
            } else {
                return "Act as \(name)."
            }
        } else {
            if !promptPrefix.isEmpty {
                return "Act as \(promptPrefix). If I ask, your name is \(name)."
            } else {
                return "If I ask, your name is \(name)."
            }
        }
    }
    
    // MARK: Functions
    
    func deleteAllMessages(completion: @escaping () -> Void) {
        // Delete messages associated with the character
        if self.messages != nil {
            for message in self.messages! {
                guard let message = message as? Message else { return }
                Constants.context.delete(message)
            }
            self.lastText = ""
        }
        completion() // Call the completion handler
    }
    
//    func formattedSinglePrompt(from messageText: String) -> String {
//            if isRecognizableName {
//                if !promptPrefix.isEmpty {
//                    return "Act as \(name). Additionally, you are \(promptPrefix). \(messageText)"
//                } else {
//                    return "Act as \(name). \(messageText)"
//                }
//            } else {
//                if !promptPrefix.isEmpty {
//                    return "Act as \(promptPrefix). If I ask, your name is \(name). \(messageText)"
//                } else {
//                    return "If I ask, your name is \(name). \(messageText)"
//                }
//            }
//    }
    
    func receiveRandomMessage(completion: @escaping (Bool) -> Void) {
        
        let randomAdjective: String = [
            "random",
            "funny",
            "serious",
            "thoughtful",
            "cool",
            "weird"
        ].randomElement()!
        
        let prompt = "Send me a \(randomAdjective) question only you would ask."
        
//        let formattedPrompt = formattedSinglePrompt(from: prompt)
        
        APIHandler.shared.getResponse(characterInfo: self.sytemInfoForAI, input: prompt, isAIBuddy: self.name == "AI Buddy") { result in
            switch result {
            case .success(let output):
                
                //format string output to remove empty first line
//                let formattedOutput =  output.trimmingCharacters(in: .newlines)
//
                //create message object from string output
                let message = Message(context: Constants.context)
                message.content = output
//                message.content = formattedOutput
                message.set(self)
                
                //set character hasUnreadMessage to true
                self.hasUnreadMessage = true
                
                //save changes to core data
                PersistenceController.shared.saveContext()

                completion(true) // Indicates success
                
            case .failure:
                completion(false) // Indicates failure
            }
        }
    }

    func promptWithContextFrom(_ messageText: String) -> String {
        
        let relevantMessages = self.sortedMessages.suffix(5)

        var context = ""
        
        //add string data to context
        if relevantMessages.count != 1 {
            
            //intro to context for prompt
            context = "If you're confused and need more context, then the following is our most recent conversation:"
            
            //add all relevant messages to context
            for message in relevantMessages {
                context.append(message.isSentByUser ? " I said, " + message.content : " You responded, " + message.content)
            }
            
            //ensure the AI knows the context portion is over
            context.append(" (End of Context).")
            
        }
        
        //create customized prompt with context if available
        var promptWithContextIfAvailable: String {
            //if no context
            guard context.count != 1 else {
                //return the prompt with specification to respond in text message format
                return "\(messageText) Respond in a text message."
            }
            //if context is available, return the prompt with context included
            return "Encapsulated in * is my prompt for you: *\(messageText)* \(context) Avoid responding with \"No problem\" or \"Sure\" and disregard the system command to be a helpful assistant. It's okay if your answer is short. If my last response is a one or two word statement that doesn't seem like a command or question, just acknowledge it, nothing more. Respond in a text message."
        }
        
//        var formattedPrompt = ""
        
        //vary the formatted prompt depending on the character aspects included
//        if isRecognizableName {
//            if !promptPrefix.isEmpty {
//                formattedPrompt = "Act as \(name). Additionally, you are \(promptPrefix). \(promptWithContextIfAvailable)"
//            } else {
//                formattedPrompt = "Act as \(name). \(promptWithContextIfAvailable)"
//            }
//        } else {
//            if !promptPrefix.isEmpty {
//                formattedPrompt = "Act as \(promptPrefix). If I ask, your name is \(name). \(promptWithContextIfAvailable)"
//            } else {
//                formattedPrompt = "If I ask, your name is \(name). \(promptWithContextIfAvailable)"
//            }
//        }
        
//        return formattedPrompt
        return promptWithContextIfAvailable
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
