//
//  APIHandlerTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

final class APIHandlerTests: XCTestCase {
    
    var apiHandler: APIHandler!
    var mockOpenAIAPI: MockOpenAIAPI!
    
    override func setUp() {
        super.setUp()
        mockOpenAIAPI = MockOpenAIAPI()
        apiHandler = APIHandler(openAIAPI: mockOpenAIAPI)
    }
    
    override func tearDown() {
        apiHandler = nil
        mockOpenAIAPI = nil
        super.tearDown()
    }
    
    func testGetResponseSuccess() {
        // Set up your mockOpenAIAPI to return a successful response
        
        apiHandler.getResponse(input: "input", isAIBuddy: true) { result in
            switch result {
            case .success(let output):
                XCTAssertEqual(output, "expectedOutput")
            case .failure(_):
                XCTFail("Expected success")
            }
        }
    }
    
    func testGetResponseFailure() {
        // Set up your mockOpenAIAPI to return a failure response
        apiHandler.shouldSucceed = false
        
        apiHandler.getResponse(input: "input", isAIBuddy: true) { result in
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

// Define MockOpenAIAPI for testing purposes
class MockAPIHandler: APIHandlerProtocol {
    
    var shouldSucceed: Bool = true // This flag determines if the mock should succeed or fail
    
    func getResponse(input: String, isAIBuddy: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        if shouldSucceed {
            let mockResponse = "Mocked Response"
            completionHandler(.success(mockResponse))
        } else {
            let error = OpenAIError.someError // Define a specific error for testing
            completionHandler(.failure(error))
        }
    }
    
}
