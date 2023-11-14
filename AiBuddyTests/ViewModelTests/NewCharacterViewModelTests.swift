////
////  NewCharacterViewModelTests.swift
////  AiBuddyTests
////
////  Created by Steven Sullivan on 11/9/23.
////
//
//import XCTest
//@testable import AiBuddy
//
//class NewCharacterViewModelTests: XCTestCase {
//
//    var viewModel: NewCharacterViewModel!
//
//    override func setUp() {
//        super.setUp()
//        viewModel = NewCharacterViewModel()
//    }
//
//    override func tearDown() {
//        viewModel = nil
//        super.tearDown()
//    }
//
//    func testIsValidForSave() {
//        // Create a Character for testing
//        let existingCharacter = Character() // Assuming Character conforms to Equatable
//
//        // Test when name is empty
//        viewModel.name = ""
//        XCTAssertFalse(viewModel.isValidForSave(existingCharacter: existingCharacter))
//
//        // Test when name is "AI Buddy"
//        viewModel.name = "AI Buddy"
//        XCTAssertFalse(viewModel.isValidForSave(existingCharacter: existingCharacter))
//
//        // Test when name is valid
//        viewModel.name = "John Doe"
//        XCTAssertTrue(viewModel.isValidForSave(existingCharacter: existingCharacter))
//    }
//
//    func testUpdateImage() {
//        // Test updating image
//        let testImage = UIImage(named: "testImage") // Assuming you have a test image in your assets
//        viewModel.updateImage(testImage)
//        XCTAssertEqual(viewModel.contactImage, testImage)
//    }
//
//    func testIsCameraAvailable() {
//        // Test when camera is available
//        XCTAssertTrue(viewModel.isCameraAvailable())
//
//        // You might want to test when camera is not available, but this depends on the actual implementation.
//    }
//
//    func testSendGreetingText() {
//        // Assuming you have a method to mock the API response for testing
//
//        let expectation = XCTestExpectation(description: "Send greeting text")
//
//        // Test successful response
//        let mockCharacter = Character() // Create a mock character
//        viewModel.sendGreetingText(from: mockCharacter) { success in
//            XCTAssertTrue(success)
//            expectation.fulfill()
//        }
//
//        // Test failure response
//        let failingMockCharacter = Character()
//        // Assuming your mock API response method can force a failure
//        viewModel.sendGreetingText(from: failingMockCharacter) { success in
//            XCTAssertFalse(success)
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 5)
//    }
//
//    func testPrefillFields() {
//        // Create a mock character
//        let mockCharacter = Character()
//        mockCharacter.name = "John Doe"
//        mockCharacter.isRecognizableName = true
//        mockCharacter.promptPrefix = "Hello, I'm John."
//
//        viewModel.prefillFields(for: mockCharacter)
//
//        XCTAssertEqual(viewModel.name, "John Doe")
//        XCTAssertTrue(viewModel.isNameRecognizable)
//        XCTAssertEqual(viewModel.aboutMe, "Hello, I'm John.")
//    }
//
//}
