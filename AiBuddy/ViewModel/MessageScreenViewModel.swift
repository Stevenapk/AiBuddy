//
//  MessageScreenViewModel.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/18/23.
//

import SwiftUI

class MessageScreenViewModel: ObservableObject {
    
    init(messages: [Message]) {
        self.messages = messages
    }
    
    @EnvironmentObject var alertManager: ErrorAlertManager
    
    // MARK: View Properties
    @Published var selectedMessage: Message? = nil
    @Published var messages: [Message]
    @Published var messageText = ""
    @Published var responseText = ""
    @Published var isTextFieldFocused = false
    @Published var textFieldHeight: CGFloat = 70
    
    // MARK: Error Properties
//    @Published var alertMessage: String = ""
//    @Published var showAlertMessage: Bool = false

    // Functions
    func unmarkUnreadMessage(for character: Character) {
        //if character has an unread message,
        if character.hasUnreadMessage {
            //set character has unread message to false, since they have now viewed it by opening this screen
            character.hasUnreadMessage = false
            //save changes to context
            PersistenceController.shared.saveContext()
        }
    }
    
    func sendMessage(to character: Character) {
        
        //create message object from messageText field
        let message = Message(context: Constants.context)
        message.content = messageText
        message.isSentByUser = true
        message.set(character)
        
        //add to array to update view
        messages.append(message)
        
        //save sent message
        PersistenceController.shared.saveContext()
        
        let prompt = character.promptWithContextFrom(messageText)
        
        //clear textfield
        messageText = ""
        
        //send message
        APIHandler.shared.sendMessage(prompt, to: character) { response in
            switch response {
            case .success(let message):
                //save changes to core data
                PersistenceController.shared.saveContext() //TODO: REMOVE THIS IF WEIRD SEND MESSAGE BEHAVIOR
                //append response to messages array
                self.messages.append(message)
                //TODO: delete these two things below after you've tested that the alert works :)
                self.alertManager.activateAlert("The message was succesful!!")
                print("SUCCESS SHOULD SHOW ALERT!!!")
            case .failure(let error):
                // Present an error alert in MessageScreen with the error
                // Set the alert message according to the specific error
                self.alertManager.activateAlert("It looks like there was an issue. \(error.localizedDescription)")
            }
        }
    }

    func getKeyboardHeight() -> CGFloat {
        return UIScreen.main.bounds.height > 800 ? 300 : 200
    }
    
}
