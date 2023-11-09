//
//  NewCharacterViewModel.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

class NewCharacterViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var aboutMe = ""
    @Published var contactImageData: Data?
    @Published var contactImage: UIImage?
    @Published var isNameRecognizable = false
    
    @Published var showEditImageActionSheet = false
    @Published var showPhotoLibrary = false
    @Published var showCapturePhoto = false

    func isValidForSave(existingCharacter: Character?) -> Bool {
        guard !name.isEmpty && name != "AI Buddy" else { return false }

        if let character = existingCharacter {
            if character.name != name || character.promptPrefix != aboutMe || character.isRecognizableName != isNameRecognizable || character.imgData != contactImageData {
                if isNameRecognizable || !aboutMe.isEmpty {
                    return true
                }
            }
        } else {
            if isNameRecognizable || !aboutMe.isEmpty {
                return true
            }
        }

        return false
    }

    func updateImage(_ image: UIImage?) {
        contactImage = image
    }
    
    func saveCharacter(existingCharacter: Character?, completion: @escaping (Bool) -> Void) {
        if let character = existingCharacter {
            // Overwriting previous character
            character.name = name
            character.promptPrefix = aboutMe
            character.isRecognizableName = isNameRecognizable
            
            // Create Image Object and assign character
            let imgData = ImageData(context: Constants.context)
            imgData.imageData = contactImageData
            imgData.character = character

            PersistenceController.shared.saveContext()
            
            completion(true) // Needs refresh
        } else {
            // Saving new character
            let newChar = Character(context: Constants.context)
            newChar.name = name
            newChar.promptPrefix = aboutMe
            newChar.isRecognizableName = isNameRecognizable
            
            // Create Image Object and assign character
            let imgData = ImageData(context: Constants.context)
            imgData.imageData = contactImageData
            imgData.character = newChar

            sendGreetingText(from: newChar, completion: { needsRefresh in
                completion(needsRefresh)
            })
        }
    }
    
    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func sendGreetingText(from newChar: Character, completion: @escaping (Bool) -> Void) {
        //define prompt from message text
        let messageText = "Greet me in a way unique to you"
        var prompt: String {
            if isNameRecognizable {
                if !aboutMe.isEmpty {
                    return "Act as \(name). Additionally, you are \(aboutMe). \(messageText)"
                } else {
                    return "Act as \(name). \(messageText)"
                }
            } else {
                if !aboutMe.isEmpty {
                    return "Act as \(aboutMe). If I ask, your name is \(name). \(messageText)"
                } else {
                    return "If I ask, your name is \(name). \(messageText)"
                }
            }
        }
        
        APIHandler.shared.getResponse(input: prompt, isAIBuddy: false) { result in
            switch result {
            case .success(let output):

                let formattedOutput = output.removeUnwantedLines
                
                //create message object from string output
                let message = Message(context: Constants.context)
                message.content = formattedOutput
                message.set(newChar)
                
                //set character hasUnreadMessage to true
                newChar.hasUnreadMessage = true
                
                //save changes to core data
                PersistenceController.shared.saveContext()

                completion(true) // Indicates success
                
            case .failure:
                completion(false) // Indicates failure
            }
        }
    }
    
    func prefillFields(for character: Character) {
            //set name
            name = character.name
            //set isFamousCharacter
            isNameRecognizable = character.isRecognizableName
            
            //set image if applicable
            if let image = character.image {
                contactImage = image
                contactImageData = character.imgData
            }
            aboutMe = character.promptPrefix
    }
    
}
