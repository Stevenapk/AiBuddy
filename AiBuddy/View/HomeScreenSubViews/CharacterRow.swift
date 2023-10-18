//
//  CharacterRow.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/16/23.
//

import SwiftUI

struct CharacterRow: View {
    @State var character: Character // Character to display
    
    var body: some View {
        HStack {
            
            // Display unread message blip if applicable
            Circle()
                .foregroundColor(character.hasUnreadMessage ? .blue : .clear)
                .frame(width: 10, height: 10)
                .padding(.leading, -5)
            
            // Display the character's contact icon
            ContactIcon(character: $character, width: 40)
            
            VStack(alignment: .leading) {
                HStack {
                    // Display the character's name
                    Text(character.name)
                        .font(.headline) // Use headline font size
                    Spacer()
                    
                    // Display the last modified timestamp
                    Text(character.modified.formattedString)
                        .font(.caption) // Use caption font size
                }
                
                // Display the last message text
                Text(character.lastText)
                    .foregroundColor(.secondary) // Use secondary text color
                    .font(.caption) // Use caption font size
                    .lineLimit(2) // Limit text to 2 lines
                
                Spacer()
            }
            .padding(.top, 5) // Add top padding
        }
    }
}

