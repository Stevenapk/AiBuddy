//
//  SearchResultsScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/10/23.
//

import SwiftUI

struct SearchResultsScreen: View {
    
    // MARK: - Properties
    
    @Binding var refreshID: UUID
    
    @State private var hasPerformedInitialSetup = false
    
    @FocusState var showKeyboard: Bool
    
    @ObservedObject var viewModel: SearchResultsViewModel
    @ObservedObject var refreshManager: RefreshManager
    
    // MARK: - Fetch Requests
    
    // Messages sorted by most recent
    @FetchRequest(
        entity: Message.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: false)]
    ) var messages: FetchedResults<Message>
    
    // Characters sorted by last modified
    @FetchRequest(
        entity: Character.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.modified, ascending: false)]
    ) var characters: FetchedResults<Character>
    
    var unreadMessageCount: Int
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(viewModel: viewModel, showKeyboard: _showKeyboard)
            Divider()
            // Display four contact icons
            ContactIconsRow(
                characters: characters,
                unreadMessageCount: unreadMessageCount,
                searchText: $viewModel.searchText,
                refreshID: $refreshID,
                refreshManager: refreshManager)
            Divider()
            // If there is typed in search text
            if !viewModel.searchText.isEmpty {
                // Display filtered messages list
                MessageSearchResultsList(messages: messages, unreadMessageCount: unreadMessageCount, searchText: $viewModel.searchText, selectedMessage: $viewModel.selectedMessage, refreshID: $refreshID, refreshManager: refreshManager)
            } else {
                ZStack {
                    Spacer()
                        .background(Color(uiColor: .systemBackground))
                }
                .background(Color(uiColor: .systemBackground))
                .onTapGesture {
                    showKeyboard = false
                }
            }
            Divider()
        }
        .navigationBarHidden(true)
        .onAppear {
            if !hasPerformedInitialSetup {
                hasPerformedInitialSetup = true
                // Automatically open the keyboard when the view appears
                showKeyboard = true
            }
        }
    }
}

struct SearchResultsScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        // Default Binding<UUID> for preview
        let refreshID = Binding<UUID>(get: {
            return UUID()
        }, set: { newValue in
        })
        
        return SearchResultsScreen(refreshID: refreshID, viewModel: SearchResultsViewModel(), refreshManager: RefreshManager(), unreadMessageCount: 0)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
