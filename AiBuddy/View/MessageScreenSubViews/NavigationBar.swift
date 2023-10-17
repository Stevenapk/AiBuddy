//
//  NavigationBar.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/17/23.
//

import SwiftUI

struct NavigationBar: View {
    
    var dismiss: () -> Void
    
    @State var character: Character
    @Binding var refreshID: UUID
    @Binding var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                // Handle back button action
                // Refresh HomeScreen for most recent message preview
                refreshID = UUID()
                // Set the text field to not be focused
                isTextFieldFocused = false
                // Dismiss current screen
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .offset(y: -17.5)
                    .bold()
            }
            Spacer()
            VStack(spacing: 0) {
                ContactIcon(character: $character, width: 50)
                Text(character.name)
                    .font(.caption2)
                    .padding(4)
            }
            Spacer()
            EmptyView() // Add a placeholder for any additional buttons/icons
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(.systemGray6))
    }
}
