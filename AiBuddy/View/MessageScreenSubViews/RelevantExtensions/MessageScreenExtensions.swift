//
//  RelevantExtensions.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/18/23.
//

import Combine
import SwiftUI

//MARK: Calendar Extensions

extension Calendar {
    // Check if a given date is within the last week.
    // - Parameter date: The date to check.
    // - Returns: `true` if the date is within the last week, otherwise `false`.
    func isDateInLastWeek(_ date: Date) -> Bool {
        guard let oneWeekAgo = self.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return date > oneWeekAgo
    }
}

// MARK: Date Extensions

extension Date {
    
    // Get a localized medium date string (e.g., "Tue, 9 28").
    var localizedMediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, M d"
        return formatter.string(from: self)
    }
    
    // "1/1/20"
    var localizedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    // "Monday"
    var dayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    // "1:00 PM
    var localizedTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    // Based on the date's proximity to today. Ex: "1:00 PM" || "Yesterday" || "Wednesday" || 1/1/20
    var formattedString: String {
        if Calendar.current.isDateInToday(self) {
            return localizedTimeString
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else if Calendar.current.isDateInLastWeek(self) {
            return dayOfWeekString
        } else {
            return localizedDateString
        }
    }
    
    // Get a long-formatted string with additional details based on the date's proximity to today.
    var longFormattedString: String {
        if Calendar.current.isDateInToday(self) {
            return localizedTimeString
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday \(localizedTimeString)"
        } else if Calendar.current.isDateInLastWeek(self) {
            return "\(dayOfWeekString) \(localizedTimeString)"
        } else {
            return "\(localizedMediumDateString) at \(localizedTimeString)"
        }
    }
}

extension Publishers {
    // A publisher for observing changes in keyboard height.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    // Get the height of the keyboard from the notification's user info.
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
