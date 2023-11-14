//
//  MessageExtensionsTest.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
import CoreData
@testable import AiBuddy

class MessageExtensionTests: XCTestCase {
    
    var mockCharacter: Character!
    var mockMessage: Message!
    
    override func setUp() {
        super.setUp()
        
        // Initialize a mock Character object
        let context = Constants.context
        mockCharacter = Character(context: context)
        mockCharacter.name = "Mock Character"
        mockCharacter.promptPrefix = "Hello"
        mockCharacter.isRecognizableName = true
        
        // Create a mock Message object
        mockMessage = Message(context: context)
        mockMessage.content = "Test Message"
        mockMessage.timestamp = Date()
        mockMessage.isSentByUser = true
        mockMessage.set(mockCharacter)
    }
    
    func testSet() {
        // Ensure the message's character is initially set to the mock character
        XCTAssertEqual(mockCharacter.lastText, "Test Message", "Last text should be set correctly")
        XCTAssertEqual(mockCharacter.modified, mockMessage.timestamp, "Modified date should be set correctly")
        
        // Update the message's character
        let newCharacter = Character(context: PersistenceController.shared.container.viewContext)
        newCharacter.name = "New Character"
        newCharacter.promptPrefix = "Hi"
        newCharacter.isRecognizableName = false
        mockMessage.set(newCharacter)
        
        // Ensure the message's character is updated correctly
        XCTAssertEqual(mockMessage.character, newCharacter, "Character should be updated correctly")
        XCTAssertEqual(newCharacter.lastText, "Test Message", "Last text should be set correctly")
        XCTAssertEqual(newCharacter.modified, mockMessage.timestamp, "Modified date should be updated correctly")
    }
}
