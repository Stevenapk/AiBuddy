//
//  MessageScreenViewModelTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
import CoreData
@testable import AiBuddy

class MessageScreenViewModelTests: XCTestCase {

    var viewModel: MockMessageScreenViewModel!
    var mockApiHandler: MockAPIHandler!
    
    var context: NSManagedObjectContext {
        viewModel.context
    }
    
    override func setUp() {
        super.setUp()
        mockApiHandler = MockAPIHandler()

        let messages: [Message] = [] // Provide test messages if needed
        viewModel = MockMessageScreenViewModel(messages: messages)
    }

    override func tearDown() {
        mockApiHandler = nil
        viewModel = nil
        super.tearDown()
    }

    func testUnmarkUnreadMessage() {
        let character = Character(context: context) // Create a test character
        character.name = "Test Character"
        character.hasUnreadMessage = true

        viewModel.unmarkUnreadMessage(for: character)

        XCTAssertFalse(character.hasUnreadMessage, "Character should not have unread message after calling unmarkUnreadMessage")
    }

    func testSendMessage() {
        let character = Character(context: context) // Create a test character
        character.name = "Test Character"

        let messageCountBefore = viewModel.messages.count

        viewModel.messageText = "How are you?"
        viewModel.sendMessage(to: character)

        let messageCountAfter = viewModel.messages.count

        XCTAssertEqual(messageCountAfter, messageCountBefore + 2, "Two messages (user's message and AI's response) should be added to the messages array")
    }

    func testGetKeyboardHeight() {
        let screenHeight = UIScreen.main.bounds.height

        if screenHeight > 800 {
            XCTAssertEqual(viewModel.getKeyboardHeight(), CGFloat(300), "Keyboard height should be 300 on devices with height > 800")
        } else {
            XCTAssertEqual(viewModel.getKeyboardHeight(), CGFloat(200), "Keyboard height should be 200 on devices with height <= 800")
        }
    }
}

// MARK: - MockMessageScreenViewModel

class MockMessageScreenViewModel: MessageScreenViewModelProtocol {
    
    var context = PersistenceController(inMemory: true).container.viewContext
    
    init(messages: [Message]) {
        self.messages = messages
    }
    
    var messages: [Message]
    
    var messageText: String = ""
    
    func unmarkUnreadMessage(for character: Character) {
        //if character has an unread message,
        if character.hasUnreadMessage {
            //set character has unread message to false, since they have now viewed it by having MessageScreenOpen
            character.hasUnreadMessage = false
        }
    }
    
    func sendMessage(to character: Character) {
        
        //create message object from messageText field
        let message = Message(context: context)
        message.content = messageText
        message.isSentByUser = true
        message.set(character)
        
        //add to array to update view
        messages.append(message)

        //clear textfield
        messageText = ""
        
        //receive message
        let response = Message(context: context)
        response.content = "Good!"
        response.set(character)
        self.messages.append(response)
    }
    
    func getKeyboardHeight() -> CGFloat {
        return UIScreen.main.bounds.height > 800 ? 300 : 200
    }
}
