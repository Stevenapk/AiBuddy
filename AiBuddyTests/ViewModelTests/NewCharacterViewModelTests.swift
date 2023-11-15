//
//  NewCharacterViewModelTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
import CoreData
@testable import AiBuddy

class NewCharacterViewModelTests: XCTestCase {

    var viewModel: MockNewCharacterViewModel!
    var context: NSManagedObjectContext {
        viewModel.context
    }

    override func setUp() {
        super.setUp()
        viewModel = MockNewCharacterViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testIsValidForSave() {
        // Create a Character for testing
        let existingCharacter = Character(context: context) // Assuming Character conforms to Equatable
        existingCharacter.name = "John Doe"

        // Test when name is empty
        viewModel.name = ""
        XCTAssertFalse(viewModel.isValidForSave(existingCharacter: existingCharacter))

        // Test when name is "AI Buddy"
        viewModel.name = "AI Buddy"
        XCTAssertFalse(viewModel.isValidForSave(existingCharacter: existingCharacter))

        // Test when name is valid
        viewModel.name = "Johnny Mick"
        viewModel.isNameRecognizable = true
        XCTAssertTrue(viewModel.isValidForSave(existingCharacter: existingCharacter))
    }

    func testPrefillFields() {
        // Create a mock character
        let mockCharacter = Character(context: context)
        mockCharacter.name = "John Doe"
        mockCharacter.isRecognizableName = true
        mockCharacter.promptPrefix = "Hello, I'm John."

        viewModel.prefillFields(for: mockCharacter)

        XCTAssertEqual(viewModel.name, "John Doe")
        XCTAssertTrue(viewModel.isNameRecognizable)
        XCTAssertEqual(viewModel.aboutMe, "Hello, I'm John.")
    }
    
    func testSaveCharacter() {
        viewModel.name = "Joe Wild"
        viewModel.isNameRecognizable = true
        
        viewModel.saveCharacter(existingCharacter: nil) { success in
            XCTAssertTrue(success)
        }
    }
}


class MockNewCharacterViewModel: NewCharacterViewModelProtocol {
    var name = ""
    var aboutMe = ""
    var contactImageData: Data?
    var contactImage: UIImage?
    var isNameRecognizable = false
    var context = PersistenceController(inMemory: true).container.viewContext

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

    func saveCharacter(existingCharacter: Character?, completion: @escaping (Bool) -> Void) {
        if let character = existingCharacter {
            // Overwriting previous character
            character.name = name
            character.promptPrefix = aboutMe
            character.isRecognizableName = isNameRecognizable
            
            // Create Image Object and assign character
            let imgData = ImageData(context: context)
            imgData.imageData = contactImageData
            imgData.character = character
            
            completion(true)
        } else {
            // Saving new character
            let newChar = Character(context: context)
            newChar.name = name
            newChar.promptPrefix = aboutMe
            newChar.isRecognizableName = isNameRecognizable
            
            // Create Image Object and assign character
            let imgData = ImageData(context: context)
            imgData.imageData = contactImageData
            imgData.character = newChar
            completion(true)
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
