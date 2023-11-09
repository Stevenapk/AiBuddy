//
//  AlertPresenter.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/6/23.
//

import SwiftUI

struct AlertPresenter: View {
    @State var isAlertPresented = false
    @State var alertMessage = ""

    var body: some View {
        VStack {
            // Button to trigger the alert
            EmptyView()

            // Modifier to present the alert
            .alert(isPresented: $isAlertPresented) {
                Alert(
                    title: Text("Alert"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Okay")) {
                        alertMessage = ""
                    }
                )
            }
        }
    }

    // Function to show the alert
    private func showAlert(with message: String) {
        alertMessage = message
        isAlertPresented = true
    }
}
