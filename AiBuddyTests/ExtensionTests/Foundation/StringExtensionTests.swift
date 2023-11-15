//
//  StringExtensionTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

class StringExtensionsTests: XCTestCase {
    
    func testRemoveUnwantedLines() {
        let inputString = """
            Line 1.
            
            Line 2
            .
            
            .Line 3
            
            .
            """
        let expectedResult = """
            Line 1.
            Line 2
            .Line 3
            """
        
        let result = inputString.removeUnwantedLines
        
        XCTAssertEqual(result, expectedResult, "Resulting string should match the expected string")
    }
    
    func testRemoveUnwantedLinesWithEmptyInput() {
        let inputString = ""
        let expectedResult = ""
        
        let result = inputString.removeUnwantedLines
        
        XCTAssertEqual(result, expectedResult, "Resulting string should be empty")
    }
    
    func testRemoveUnwantedLinesWithAllPeriods() {
        let inputString = "......"
        let expectedResult = "......"
        
        let result = inputString.removeUnwantedLines
        
        XCTAssertEqual(result, expectedResult, "Resulting string should be identical")
    }
    
}
