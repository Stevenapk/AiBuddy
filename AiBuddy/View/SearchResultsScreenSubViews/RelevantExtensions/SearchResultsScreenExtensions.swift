//
//  SearchResultsScreenExtensions.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

extension String {
    
    func highlighted(letters: String) -> AttributedString {
        
        //convert original string to NSMutableAttributedString
        let highlightedString = NSMutableAttributedString(string: self)
        
        //set original gray color
        let entireRange = NSRange(location: 0, length: highlightedString.length)
        highlightedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: entireRange)
        
        //highlight in black the letters which were searched
        let range = self.range(of: letters, options: .caseInsensitive)
        if range != nil {
            highlightedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(range!, in: self))
        }

        //Return AttributedString for use in Text()
        return AttributedString(highlightedString)
    }
    
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}
