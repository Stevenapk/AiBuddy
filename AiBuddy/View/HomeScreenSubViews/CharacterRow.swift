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
                .padding(.leading, -7.5)
                .padding(.trailing, -1.0)
            
            // Display the character's contact icon
            ContactIcon(character: $character, width: 45)
                .padding(.trailing, 5.0)
            
            VStack(alignment: .leading) {
                HStack {
                    // Display the character's name
                    Text(character.name)
                        .font(.headline) // Use headline font size
                    Spacer()
                    
                    // Display the last modified timestamp
                    Text(character.modified.formattedString)
                        .font(.system(size: 14.5)) // Use caption font size
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 5)
                    
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .foregroundColor(.secondary)
                }
                
                // Display the last message text
                Text(character.lastText)
                    .foregroundColor(.secondary) // Use secondary text color
                    .font(.system(size: 15))
                    .lineLimit(2) // Limit text to 2 lines
                    .padding(.trailing, 20)
                if character.lastText.isEmpty {
                                    Spacer()
                        .frame(height: 10)
                }
            }
            Spacer()
                .frame(width: 20)
//            .padding(.top, 5) // Add top padding
        }
    }
}
