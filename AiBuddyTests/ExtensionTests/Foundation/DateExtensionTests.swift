//
//  DateExtensionTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

class DateExtensionsTests: XCTestCase {
    
    func testLocalizedMediumDateString() {
        let date = Date(timeIntervalSince1970: 1634851200) // Oct 22, 2021
        let result = date.localizedMediumDateString
        XCTAssertEqual(result, "Fri, 10 22", "Resulting string should match the expected string")
    }
    
    func testLocalizedDateString() {
        let date = Date(timeIntervalSince1970: 1634851200) // Oct 22, 2021
        let result = date.localizedDateString
        XCTAssertEqual(result, "10/22/21", "Resulting string should match the expected string")
    }
    
    func testDayOfWeekString() {
        let date = Date(timeIntervalSince1970: 1634851200) // Oct 22, 2021 (a Friday)
        let result = date.dayOfWeekString
        XCTAssertEqual(result, "Friday", "Resulting string should match the expected string")
    }
    
    func testLocalizedTimeString() {
        let date = Date(timeIntervalSince1970: 1634851200) // Oct 22, 2021
        let result = date.localizedTimeString
        XCTAssertEqual(result, "12:00 AM", "Resulting string should match the expected string")
    }
    
    func testFormattedStringToday() {
        let date = Date()
        let result = date.formattedString
        XCTAssertEqual(result, date.localizedTimeString, "Resulting string should match the current time")
    }
    
    func testFormattedStringYesterday() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let result = yesterday.formattedString
        XCTAssertEqual(result, "Yesterday", "Resulting string should be 'Yesterday'")
    }
    
    func testFormattedStringLastWeek() {
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -6, to: Date())!
        let result = lastWeek.formattedString
        XCTAssertEqual(result, lastWeek.dayOfWeekString, "Resulting string should be the day of the week")
    }
    
    func testLongFormattedStringToday() {
        let date = Date()
        let result = date.longFormattedString
        XCTAssertEqual(result, date.localizedTimeString, "Resulting string should match the current time")
    }
    
    func testLongFormattedStringYesterday() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let result = yesterday.longFormattedString
        XCTAssertEqual(result, "Yesterday \(yesterday.localizedTimeString)", "Resulting string should be 'Yesterday <time>'")
    }
    
    func testLongFormattedStringLastWeek() {
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -6, to: Date())!
        let result = lastWeek.longFormattedString
        XCTAssertEqual(result, "\(lastWeek.dayOfWeekString) \(lastWeek.localizedTimeString)", "Resulting string should be '<day> <time>'")
    }
    
    func testLongFormattedStringOther() {
        let date = Date(timeIntervalSince1970: 1634851200) // Oct 22, 2021
        let result = date.longFormattedString
        XCTAssertEqual(result, "Fri, 10 22 at 12:00 AM", "Resulting string should match the expected string")
    }
    
}
