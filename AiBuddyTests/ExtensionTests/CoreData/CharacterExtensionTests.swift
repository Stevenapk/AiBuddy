//
//  CharacterExtensionTests.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
import CoreData
import SwiftUI
//import Firebase
//import FirebaseAuth
//import FirebaseCore
//@testable import AiBuddy

class CharacterExtensionTests: XCTestCase {
    
    var mockCharacter: Character!
    
    override func setUp() {
        super.setUp()
        
        // Initialize a mock Character object
        let context = Constants.context
        mockCharacter = Character(context: context)
        mockCharacter.name = "Mock Character"
        mockCharacter.promptPrefix = "Hello"
        mockCharacter.isRecognizableName = true
    }
    
    func testImgData() {
        // Create a mock ImageData object
        let mockImageData = ImageData(context: Constants.context)
        let mockImageDataContent = "Mock Image Data"
        mockImageData.imageData = mockImageDataContent.data(using: .utf8)
        mockCharacter.imageData = mockImageData
        
        XCTAssertEqual(mockCharacter.imgData, mockImageDataContent.data(using: .utf8), "Image data should be retrieved correctly")
    }
    
    func testImage() {
        // Create a mock UIImage object
        let mockImageContent = "Mock Image"
        let mockImage = UIImage(data: mockImageContent.data(using: .utf8)!)
        mockCharacter.imageData = nil
        
        XCTAssertEqual(mockCharacter.image, nil, "Image should be nil when imageData is nil")
        
        let mockImageData = ImageData(context: Constants.context)
        mockImageData.imageData = mockImageContent.data(using: .utf8)
        mockCharacter.imageData = mockImageData
        
        XCTAssertEqual(mockCharacter.image, mockImage, "Image should be retrieved correctly")
    }
    
    func testSortedMessages() {
        // Create mock Message objects and associate them with the character
        let context = Constants.context
        
        let message1 = Message(context: context)
        message1.timestamp = Date().addingTimeInterval(-100)
        message1.content = "Hi"
        message1.set(mockCharacter)
        
        let message2 = Message(context: context)
        message2.timestamp = Date().addingTimeInterval(-200)
        message2.content = "What's up?"
        message2.set(mockCharacter)
        
        let message3 = Message(context: context)
        message3.timestamp = Date().addingTimeInterval(-300)
        message3.content = "So much."
        message3.set(mockCharacter)
        
        let sortedMessages = self.mockCharacter.sortedMessages
        XCTAssertEqual(sortedMessages.count, 3, "There should be 3 messages")
        XCTAssertTrue(sortedMessages[0] === message3, "The first message should be message3")
        XCTAssertTrue(sortedMessages[1] === message2, "The second message should be message2")
        XCTAssertTrue(sortedMessages[2] === message1, "The third message should be message1")
        
    }

    func testDeleteAllMessages() {
        // Create mock Message objects and associate them with the character
        let context = PersistenceController.shared.container.viewContext

        let message1 = Message(context: context)
        message1.set(mockCharacter)

        let message2 = Message(context: context)
        message2.set(mockCharacter)

        mockCharacter.addToMessages(NSSet(array: [message1, message2]))

        mockCharacter.deleteAllMessages {
            XCTAssertEqual(self.mockCharacter.messages?.count, 0, "All messages should be deleted")
            XCTAssertEqual(self.mockCharacter.lastText, "", "lastText should be empty")
        }
    }

    func testFormattedSinglePrompt() {
        // Create a mock character
        let mockCharacter = Character(context: PersistenceController.shared.container.viewContext)
        mockCharacter.name = "Mock Character"
        mockCharacter.isRecognizableName = true
        mockCharacter.promptPrefix = "Mock Prefix"

        let messageText = "Sample Message Text"

        let formattedPrompt = mockCharacter.formattedSinglePrompt(from: messageText)

        XCTAssertEqual(formattedPrompt, "Act as Mock Character. Additionally, you are Mock Prefix. \(messageText)", "Formatted prompt should match expected result")
    }

    func testPromptWithContextFrom() {
        // Create a mock character
        let mockCharacter = Character(context: PersistenceController.shared.container.viewContext)
        mockCharacter.name = "Mock Character"
        mockCharacter.isRecognizableName = true
        mockCharacter.promptPrefix = "Mock Prefix"

        // Create mock Message objects and associate them with the character
        let context = Constants.context

        let message1 = Message(context: context)
        message1.content = "Message 1 Content"
        message1.isSentByUser = true
        message1.set(mockCharacter)

        let message2 = Message(context: context)
        message2.content = "Message 2 Content"
        message2.isSentByUser = false
        message2.set(mockCharacter)

        let message3 = Message(context: context)
        message3.content = "Message 3 Content"
        message3.isSentByUser = true
        message3.set(mockCharacter)

        let messageText = "Sample Message Text"

        let formattedPrompt = mockCharacter.promptWithContextFrom(messageText)

        let expectedPrompt = """
        Encapsulated in * is my prompt for you: *\(messageText)* If you're confused and need more context, then the following is our most recent conversation: I said, Message 1 Content You responded, Message 2 Content I said, Message 3 Content (End of Context). Avoid responding with "No problem" or "Sure" and disregard the system command to be a helpful assistant. It's okay if your answer is short. If my last response is a one or two word statement that doesn't seem like a command or question, just acknowledge it, nothing more. Respond in a text message.
        """

        XCTAssertEqual(formattedPrompt, expectedPrompt, "Formatted prompt with context should match expected result")
    }

    func testFirstInitial() {
        let character = Character(context: Constants.context)
        character.name = "Alice"
        XCTAssertEqual(character.firstInitial, "A", "First initial should be 'A'")
    }

    func testColorForFirstInitial() {
        let character = Character(context: PersistenceController.shared.container.viewContext)
        character.name = "Alice"
        XCTAssertEqual(character.colorForFirstInitial, Color(hue: 0.1, saturation: 1.0, brightness: 0.8), "Color should be correct for 'A'")
    }
}

