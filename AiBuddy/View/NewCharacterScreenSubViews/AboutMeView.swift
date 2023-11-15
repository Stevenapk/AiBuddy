//
//  AboutMeView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct AboutMeView: View {
    @Binding var aboutMe: String
    @Binding var isNameRecognizable: Bool
    @Binding var isKeyboardShowing: Bool

    var body: some View {
        VStack(alignment: .leading) {
            // HStack for the title and info button
            HStack {
                // Display about me field header based on name recognizability
                Text(isNameRecognizable ? "About (Optional)" : "About (Required)")
                    .font(.headline)
                Spacer()
                // Navigate to AboutTipsScreen for additional information if the info button is tapped
                NavigationLink {
                    AboutTipsScreen()
                } label: {
                    // Info button with an arrow icon
                    Capsule()
                        .stroke(Color.blue, lineWidth: 1.5) // Outline with blue color
                        .overlay(
                            HStack(spacing: 2.5) {
                                Image(systemName: "info.circle")
                                Image(systemName: "chevron.right")
                            }
                        )
                        .frame(width: 50, height: 25)
                }
                
            }
            .padding(.horizontal)
            
            // TextEditor for inputting the user's about me
            TextEditor(text: $aboutMe)
                .frame(height: 165)
                // Display character count in an overlay, ex: "221/350" (character count)
                .overlay(
                    Text("\(aboutMe.count)/350")
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .offset(y: -2.5)
                        .padding(.top, 4)
                        .padding(.horizontal, 6)
                        .font(Font.caption2)
                        .bold()
                        .background(Color.secondary
                            .cornerRadius(8))
                            .offset(x: -5, y: -5)
                        .opacity(aboutMe.isEmpty ? 0 : 1)
                    , alignment: .bottomTrailing)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
                .padding(.horizontal)
        }
        // Prevent About Me String and Editor Input Field from exceeding 350 characters
        .onChange(of: aboutMe) { newText in
            if newText.count > 350 {
                aboutMe = String(newText.prefix(350))
            }
        }
    }
}
