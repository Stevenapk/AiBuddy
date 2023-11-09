//
//  MessageScreenViewModelTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

class MessageScreenViewModelTests: XCTestCase {

    var viewModel: MessageScreenViewModel!

    override func setUp() {
        super.setUp()

        let messages: [Message] = [] // Provide test messages if needed

        viewModel = MessageScreenViewModel(messages: messages)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testUnmarkUnreadMessage() {
        let character = Character(context: Constants.context) // Create a test character
        character.name = "Test Character"
        character.hasUnreadMessage = true

        viewModel.unmarkUnreadMessage(for: character)

        XCTAssertFalse(character.hasUnreadMessage, "Character should not have unread message after calling unmarkUnreadMessage")
    }

    func testSendMessage() {
        let character = Character(context: Constants.context) // Create a test character
        character.name = "Test Character"

        let messageCountBefore = viewModel.messages.count

        viewModel.messageText = "Test Message"
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
