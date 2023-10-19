//
//  RelevantExtensions.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/18/23.
//

import Combine
import SwiftUI

extension Calendar {
    func isDateInLastWeek(_ date: Date) -> Bool {
        guard let oneWeekAgo = self.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return date > oneWeekAgo
    }
}

extension Date {
    
    var localizedMediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, M d"
        return formatter.string(from: self)
    }
    
    var localizedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    var dayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    var localizedTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
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
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
