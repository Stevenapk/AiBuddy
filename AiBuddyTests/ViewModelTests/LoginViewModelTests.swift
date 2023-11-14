//
//  LoginViewModelTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

class LoginViewModelTests: XCTestCase {
    
    var mockLoginViewModel: MockLoginViewModel!
    
    override func setUp() {
        super.setUp()
        mockLoginViewModel = MockLoginViewModel()
    }
    
    override func tearDown() {
        mockLoginViewModel = nil
    }
    
//    func testHandleError() {
//        // Simulate an error
//        let testError = NSError(domain: "com.yourapp.error", code: 42, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
//        
//        // Call handleError
//        loginViewModel.handleError(error: testError)
//        
//        // Check if errorMessage and showError are updated
//        XCTAssertEqual(loginViewModel.errorMessage, "Test Error")
//        XCTAssertTrue(loginViewModel.showError)
//    }
    
    func testSha256() {
        let inputString = "Hello, World!"
        let expectedOutput = "dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f"
        
        let hashedString = sha256(inputString)
        XCTAssertEqual(hashedString, expectedOutput)
    }
    
    func testMockAppleAuthenticate() {
        mockLoginViewModel.mockAppleAuthenticate(shouldSucceed: true)
        XCTAssertTrue(mockLoginViewModel.logStatus)
    }
    
    func testMockAppleAuthenticationFailed() {
        mockLoginViewModel.mockAppleAuthenticate(shouldSucceed: false)
        XCTAssertFalse(mockLoginViewModel.logStatus)
    }

}


// Define MockLoginViewModel for testing purposes
class MockLoginViewModel: LoginViewModelProtocol {

    //MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    //MARK: App Log Status
    var logStatus: Bool = false
    
    //MARK: Apple Signin Properties
    @Published var nonce: String = ""
    
    //MARK: Error Handling
    func handleError(error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    //MARK: Mock Apple Authenticate
    func mockAppleAuthenticate(shouldSucceed: Bool) {
        guard shouldSucceed else {return}
        self.logStatus = true
    }
    
}
