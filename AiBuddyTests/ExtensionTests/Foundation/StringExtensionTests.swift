//
//  StringExtensionTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

class StringExtensionsTests: XCTestCase {
    
//    func testHighlighted() {
//        let originalString = "Hello, World!"
//        let searchString = "World"
//        
//        let attributedString = originalString.highlighted(letters: searchString)
//        
//        // Validate the attributes of the attributed string
//        let nsRange = NSRange(location: 7, length: 5) // Range of "World" in the original string
//        let color = attributedString.getAttributes(at: nsRange, effectiveRange: nil)[.foregroundColor] as? UIColor
//        XCTAssertEqual(color, UIColor.label, "Highlighted text should have label color")
//    }
    
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
