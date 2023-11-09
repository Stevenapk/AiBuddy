//
//  MessageSearchResultsList.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct MessageSearchResultsList: View {
    var messages: FetchedResults<Message>
    var unreadMessageCount: Int
    @Binding var searchText: String
    @Binding var selectedMessage: Message?
    @Binding var refreshID: UUID
    
    @ObservedObject var refreshManager: RefreshManager
    
    var body: some View {
        // Use Core Data fetch request to filter messages
        // Iterate through results and display CharacterRow for each
        List(messages.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }) { message in
            
            NavigationLink {
                let character = message.character
                let messages = character.sortedMessages
                let indexToScrollTo = messages.firstIndex(of: message)
                
                // Initialize message screen's view model
                let messageScreenViewModel = MessageScreenViewModel(messages: messages)
                
                //present message screen passing optional index variable
                MessageScreen(
                    viewModel: messageScreenViewModel, refreshManager: refreshManager, refreshID: $refreshID, character: character,
                    messageIndexToScrollTo: indexToScrollTo,
                    unreadMessageCount: unreadMessageCount
                )
            } label: {
                MessageRow(message: message, lettersToHighlight: searchText)
            }
        }
        .listStyle(PlainListStyle()) // Use .plain style
    }
}
