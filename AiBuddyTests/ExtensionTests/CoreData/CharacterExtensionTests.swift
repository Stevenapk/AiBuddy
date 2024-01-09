//
//  CharacterExtensionTests.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
import CoreData
import SwiftUI

class CharacterExtensionTests: XCTestCase {
    
    var mockCharacter: Character!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Initialize a mock Character object
        context = PersistenceController(inMemory: true).container.viewContext
        mockCharacter = Character(context: context)
        mockCharacter.name = "Mock Character"
        mockCharacter.promptPrefix = "Hello"
        mockCharacter.isRecognizableName = true
    }
    
    override func tearDown() {
        mockCharacter = nil
        context = nil
        super.tearDown()
    }

    func testDeleteAllMessages() {
        // Create mock Message objects and associate them with the character
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

//    func testFormattedSinglePrompt() {
//        // Create a mock character
//        let mockCharacter = Character(context: context)
//        mockCharacter.name = "Mock Character"
//        mockCharacter.isRecognizableName = true
//        mockCharacter.promptPrefix = "Mock Prefix"
//
//        let messageText = "Sample Message Text"
//
//        let formattedPrompt = mockCharacter.formattedSinglePrompt(from: messageText)
//
//        XCTAssertEqual(formattedPrompt, "Act as Mock Character. Additionally, you are Mock Prefix. \(messageText)", "Formatted prompt should match expected result")
//    }

    func testFirstInitial() {
        let character = Character(context: context)
        character.name = "Alice"
        XCTAssertEqual(character.firstInitial, "A", "First initial should be 'A'")
    }

    func testColorForFirstInitial() {
        let character = Character(context: context)
        character.name = "Alice"
        XCTAssertEqual(character.colorForFirstInitial, Color(hue: 0.1, saturation: 1.0, brightness: 0.8), "Color should be correct for 'A'")
    }
}

