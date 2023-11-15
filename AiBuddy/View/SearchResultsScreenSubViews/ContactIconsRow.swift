//
//  ContactIconsRow.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct ContactIconsRow: View {
    
    // MARK: - Properties
    
    var characters: FetchedResults<Character>
    var unreadMessageCount: Int
    
    @Binding var searchText: String
    @Binding var refreshID: UUID
    @ObservedObject var refreshManager: RefreshManager
    
    // Diameter of each contact circle in the row
    let diameter = (UIScreen.main.bounds.width-160) / 4
    
    // MARK: - Body
    
    var body: some View {
        
        // Filter characters based on search text
        let filteredCharacters = characters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        
        // HStack for contact icons
        HStack(spacing: 30) {
            
            if !filteredCharacters.isEmpty {
                
                // Display up to 4 contact circles for filtered characters
                ForEach(filteredCharacters.prefix(4), id: \.id) { character in
                    
                    // Navigation link to MessageScreen
                    NavigationLink {
                        // Initialize message screen's view model
                        let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                        
                        MessageScreen(viewModel: messageScreenViewModel, refreshManager: refreshManager, refreshID: $refreshID, character: character, unreadMessageCount: unreadMessageCount)
                    } label: {
                        VStack {
                            // Circular background with character's first initial
                            Circle()
                                .foregroundColor(character.colorForFirstInitial) // Adjust color as needed
                                .frame(width: diameter)
                                .overlay(Text(character.firstInitial).foregroundColor(.white))
                            
                            // Character name with search text highlighting
                            Text(character.name.highlighted(letters: searchText))
                                .font(.caption2)
                                .lineLimit(1)
                                .frame(maxWidth: diameter)
                        }
                    }
                }
                .padding(.vertical)
            } else {
                
                // Display up to 4 contact circles for all characters
                ForEach(characters.prefix(4), id: \.id) { character in
                    
                    // Navigation link to the message screen
                    NavigationLink {
                        // Initialize message screen's view model
                        let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                        
                        MessageScreen(viewModel: messageScreenViewModel, refreshManager: refreshManager, refreshID: $refreshID, character: character, unreadMessageCount: unreadMessageCount)
                    } label: {
                        VStack {
                            // Circular background with character's first initial
                            Circle()
                                .foregroundColor(character.colorForFirstInitial) // Adjust color as needed
                                .frame(width: diameter)
                                .overlay(Text(character.firstInitial).foregroundColor(.white))
                            
                            // Character name
                            Text(character.name)
                                .font(.caption2)
                                .lineLimit(1)
                                .frame(maxWidth: diameter)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .padding(.horizontal, 30)
    }
}
