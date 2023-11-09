//
//  LoginViewModelTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

class LoginViewModelTests: XCTestCase {
    
    var loginViewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()
        loginViewModel = LoginViewModel()
    }
    
    override func tearDown() {
        loginViewModel = nil
        super.tearDown()
    }
    
    func testHandleError() {
        // Simulate an error
        let testError = NSError(domain: "com.yourapp.error", code: 42, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        
        // Call handleError
        loginViewModel.handleError(error: testError)
        
        // Check if errorMessage and showError are updated
        XCTAssertEqual(loginViewModel.errorMessage, "Test Error")
        XCTAssertTrue(loginViewModel.showError)
    }
    
    func testSha256() {
        let inputString = "Hello, World!"
        let expectedOutput = "3ad77bb40b4c187f7c16b7b9a1f3c724f40a0a1c4a9079b633d28a9f95836d6a"
        
        let hashedString = sha256(inputString)
        XCTAssertEqual(hashedString, expectedOutput)
    }
    
    // Add more tests as needed...
}
