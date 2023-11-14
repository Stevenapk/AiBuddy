//
//  CalendarExtensionTests.swift
//  AiBuddyTests
//
//  Created by Steven Sullivan on 11/9/23.
//

import XCTest
@testable import AiBuddy

class CalendarExtensionsTests: XCTestCase {

    func testIsDateInLastWeek() {
        let calendar = Calendar.current

        // Test with a date that is exactly one week ago
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        XCTAssertFalse(calendar.isDateInLastWeek(oneWeekAgo), "Date should not be in last week")

        // Test with a date that is more than one week ago
        let moreThanOneWeekAgo = calendar.date(byAdding: .day, value: -8, to: Date())!
        XCTAssertFalse(calendar.isDateInLastWeek(moreThanOneWeekAgo), "Date should not be in last week")

        // Test with a date that is less than one week ago
        let lessThanOneWeekAgo = calendar.date(byAdding: .day, value: -6, to: Date())!
        XCTAssertTrue(calendar.isDateInLastWeek(lessThanOneWeekAgo), "Date should be in last week")
    }

}
