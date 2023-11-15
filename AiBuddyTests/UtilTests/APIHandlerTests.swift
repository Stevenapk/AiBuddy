//
//  APIHandlerTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
import OpenAISwift
@testable import AiBuddy

final class APIHandlerTests: XCTestCase {
    
    var mockApiHandler: MockAPIHandler!
    
    override func setUp() {
        super.setUp()
        mockApiHandler = MockAPIHandler()
    }
    
    override func tearDown() {
        mockApiHandler = nil
        super.tearDown()
    }
    
    func testGetResponseSuccess() {
        // Set up mockApiHandler to return a successful response
        mockApiHandler.getResponse(input: "input", isAIBuddy: true) { result in
            switch result {
            case .success(let output):
                XCTAssertEqual(output, "Mocked Response")
            case .failure(_):
                XCTFail("Expected success")
            }
        }
    }
    
    func testGetResponseFailure() {
        // Set up mockApiHandler to return a failure response
        mockApiHandler.shouldSucceed = false
        
        mockApiHandler.getResponse(input: "input", isAIBuddy: true) { result in
            switch result {
            case .success(_):
                XCTFail("Expected failure")
            case .failure(_):
                // This is expected
                break
            }
        }
    }
}

// Define a specific error for testing
enum OpenAIError: Error {
    case someError // Add a specific error case for testing
}

// MARK: - MockAPIHandler

class MockAPIHandler: APIHandlerProtocol {
    
    var shouldSucceed: Bool = true // This flag determines if the mock should succeed or fail
    
    func getResponse(input: String, isAIBuddy: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        if shouldSucceed {
            let mockResponse = "Mocked Response"
            completion(.success(mockResponse))
        } else {
            let error = OpenAIError.someError // Define a specific error for testing
            completion(.failure(error))
        }
    }
}
