//
//  ContactIconsRow.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct ContactIconsRow: View {
    
    var characters: FetchedResults<Character>
    var unreadMessageCount: Int
    
    @Binding var searchText: String
    @Binding var refreshID: UUID
    @ObservedObject var refreshManager: RefreshManager
    
    let diameter = (UIScreen.main.bounds.width-160) / 4

    var body: some View {
        
        let filteredCharacters = characters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            HStack(spacing: 30) {
                
                if !filteredCharacters.isEmpty {
                    
                    ForEach(filteredCharacters.prefix(4), id: \.id) { character in
                        
                        NavigationLink {
                            // Initialize message screen's view model
                            let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                            
                            MessageScreen(viewModel: messageScreenViewModel, refreshManager: refreshManager, refreshID: $refreshID, character: character, unreadMessageCount: unreadMessageCount)
                        } label: {
                            VStack {
                                Circle()
                                    .foregroundColor(character.colorForFirstInitial) // Adjust color as needed
                                    .frame(width: diameter)
                                    .overlay(Text(character.firstInitial).foregroundColor(.white))
                                Text(character.name.highlighted(letters: searchText))
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .frame(maxWidth: diameter)
                            }
                        }
                    }
                    .padding(.vertical)
                } else {
                    ForEach(characters.prefix(4), id: \.id) { character in
                        NavigationLink {
                            // Initialize message screen's view model
                            let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                            
                            MessageScreen(viewModel: messageScreenViewModel, refreshManager: refreshManager, refreshID: $refreshID, character: character, unreadMessageCount: unreadMessageCount)
                        } label: {
                            VStack {
                                Circle()
                                    .foregroundColor(character.colorForFirstInitial) // Adjust color as needed
                                    .frame(width: diameter)
                                    .overlay(Text(character.firstInitial).foregroundColor(.white))
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
