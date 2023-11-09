//
//  AlertManager.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/8/23.
//

import SwiftUI

struct RelevantError: Identifiable {
    var id: UUID = UUID()
    var message: String = ""
}

class ErrorAlertManager: ObservableObject {
    
    @Published var showAlert = false
    @Published var message: String = ""
    @Published var errorForMessageScreen: RelevantError?
    @Published var errorForHomeScreen: RelevantError?

    func activateAlert(_ message: String ) {
        self.message = message
        showAlert = true
    }

    func dismissAlert() {
        showAlert = false
    }

    func handleAlertDismissed() {
        // Handle any actions after alert is dismissed
    }
}
