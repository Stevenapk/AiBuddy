//
//  HomeScreenViewModelTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
import CoreData
@testable import AiBuddy

class HomeScreenViewModelTests: XCTestCase {

    var viewModel: MockHomeScreenViewModel!
    var context: NSManagedObjectContext {
        viewModel.context
    }

    override func setUp() {
        super.setUp()
        viewModel = MockHomeScreenViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testRollForRandomNewMessage() {
        let character = Character(context: context) // Create a test character
        character.name = "Test Character"
        
        let expectation = self.expectation(description: "Message received successfully")
        
        viewModel.rollForRandomNewMessage(from: character) { success in
            XCTAssertTrue(success, "Random message should be received successfully")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testCreateDefaultCharactersIfNeeded() {
        do {
            let characterCountBefore = try context.fetch(Character.fetchRequest()).count

            viewModel.createDefaultCharactersIfNeeded()

            let characterCountAfter = try context.fetch(Character.fetchRequest()).count

            XCTAssertGreaterThan(characterCountAfter, characterCountBefore, "Default characters should be created")
        } catch {
            XCTFail("Error fetching Character entities: \(error)")
        }
    }

    
    func testHasUserOpenedAppBefore() {
            let hasOpenedBefore = viewModel.hasUserOpenedAppBefore()
            XCTAssertFalse(hasOpenedBefore, "User should be considered as NOT having opened the app before")
    }
}


class MockHomeScreenViewModel: HomeScreenViewModelProtocol {
    
    var context = PersistenceController(inMemory: true).container.viewContext
    
    func rollForRandomNewMessage(from character: Character, completion: @escaping (Bool) -> Void) {
        
        let probability = 1
        
        if probability == 1 {
            // Select a random character
            let message = Message(context: context)
            message.content = "random message"
            message.set(character)
            completion(true)
        }
    }

    func createDefaultCharactersIfNeeded() {
        
        guard !hasUserOpenedAppBefore() else { return }
        
        let charactersData: [(name: String, promptPrefix: String, lastText: String, isFamous: Bool)] = [
            ("That 70's Guy", "a 17 year old friend from the era of the 1970's who responds in slang and loves to go dancing and to the movies", "Hey dude", false)
        ]
        
        for data in charactersData {
            //create character
            let character = Character(context: context)
            character.name = data.name
            character.promptPrefix = data.promptPrefix
            character.isRecognizableName = data.isFamous
            
            //create your constant message
            let message = Message(context: context)
            message.isSentByUser = true
            message.content = "How's it going?"
            message.set(character)
            
            //create their variable message
            let response = Message(context: context)
            response.isSentByUser = false
            response.content = data.lastText
            response.set(character)
            
            character.addToMessages(message)
            character.addToMessages(response)
             
        }
    }
    
    func hasUserOpenedAppBefore() -> Bool {
        do {
            let appStatus = try context.fetch(AppStatus.fetchRequest())
            if !appStatus.isEmpty {
                return true
            } else {
                let appStatus = AppStatus(context: context)
                appStatus.hasBeenOpenedBefore = true
                return false
            }
        } catch {
            let appStatus = AppStatus(context: context)
            appStatus.hasBeenOpenedBefore = true
            return false
        }
    }

}
