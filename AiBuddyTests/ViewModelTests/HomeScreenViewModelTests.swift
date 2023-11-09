//
//  HomeScreenViewModelTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

class HomeScreenViewModelTests: XCTestCase {

    var viewModel: HomeScreenViewModel!

    override func setUp() {
        super.setUp()
        viewModel = HomeScreenViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testRollForRandomNewMessage() {
        let character = Character(context: Constants.context) // Create a test character
        character.name = "Test Character"
        
        let expectation = self.expectation(description: "Message received successfully")
        
        viewModel.rollForRandomNewMessage(from: character) { success in
            XCTAssertTrue(success, "Random message should be received successfully")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testCreateDefaultCharactersIfNeeded() {
        let characterCountBefore = Constants.context.fetch(Character.fetchRequest()).count

        viewModel.createDefaultCharactersIfNeeded()

        let characterCountAfter = Constants.context.fetch(Character.fetchRequest()).count

        XCTAssertGreaterThan(characterCountAfter, characterCountBefore, "Default characters should be created")
    }

    func testHasUserOpenedAppBefore() {
        let appStatusCountBefore = Constants.context.fetch(AppStatus.fetchRequest()).count

        let hasOpenedBefore = viewModel.hasUserOpenedAppBefore()

        let appStatusCountAfter = Constants.context.fetch(AppStatus.fetchRequest()).count

        XCTAssertTrue(hasOpenedBefore, "User should be considered as having opened the app before")
        XCTAssertEqual(appStatusCountAfter, appStatusCountBefore + 1, "AppStatus entity count should increase by 1")
    }
}
