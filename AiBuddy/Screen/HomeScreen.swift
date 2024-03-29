//
//  HomeScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Combine
import CoreData

class RefreshManager: ObservableObject {
    @Published var shouldRefresh = false
}

struct HomeScreen: View {
 
    @EnvironmentObject var persistenceController: PersistenceController
    @ObservedObject var viewModel: HomeScreenViewModel
    @ObservedObject var refreshManager: RefreshManager
    
    // MARK: - State Properties
    
    @State private var refreshID = UUID() // Unique identifier for view refreshing
    @State private var hasPerformedInitialSetup = false
    @State private var shouldUpdate = false
    
    // Characters Fetch Request sorted by last modified
    @FetchRequest(
        entity: Character.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.modified, ascending: false)]
    ) var characters: FetchedResults<Character>
    
    var unreadMessageCount: Int {
        let total = characters.reduce(0) { result, character in
            return result + (character.hasUnreadMessage ? 1 : 0)
        }
        return total
    }
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationLink {
                    SearchResultsScreen(refreshID: $refreshID, viewModel: SearchResultsViewModel(), refreshManager: refreshManager, unreadMessageCount: unreadMessageCount) // Show search results screen
                } label: {
                    // Search bar for filtering characters
                    SearchBar(isTextFieldDisabled: true, text: $viewModel.searchText)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12.5)
                }
                Divider()
                
                List(characters) { character in
                    NavigationLink {
                        // Initialize messageScreen's view model passing the character's sorted messages
                        let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                        
                        // Show the Message Screen for selected character
                        MessageScreen(viewModel: messageScreenViewModel, refreshManager: refreshManager, refreshID: $refreshID, character: character, unreadMessageCount: unreadMessageCount)
                    } label: {
                        CharacterRow(character: character) // Display character information
                            .contextMenu {
                                // Context menu options
                                // add edit character button if it's not AI Buddy
                                if character.name != "AI Buddy" {
                                    Button(action: {
                                        viewModel.characterToEdit = character // Edit character action
                                    }) {
                                        Text("Edit Character")
                                        Image(systemName: "pencil")
                                    }
                                }
                                
                                Button(action: {
                                    viewModel.selectedActionSheet = .deleteMessages(character) // Delete messages action
                                }) {
                                    Text("Delete Messages")
                                    Image(systemName: "trash")
                                }
                                
                                //add delete character button if it's not AI Buddy
                                if character.name != "AI Buddy" {
                                    Button(action: {
                                        viewModel.selectedActionSheet = .deleteCharacter(character) // Delete character action
                                    }) {
                                        Text("Delete Character")
                                        Image(systemName: "trash.fill")
                                    }
                                }
                            }
                    }
                    .listRowInsets(EdgeInsets(top: 12.5, leading: 20, bottom: 12.5, trailing: -20))
                }
                .listStyle(PlainListStyle()) // Use .plain style
                .fullScreenCover(item: $viewModel.characterToEdit) { character in
                    NewCharacterScreen(refreshID: $refreshID, viewModel: NewCharacterViewModel(), character: character) // Show new character screen for editing
                }
                .sheet(isPresented: $viewModel.showingNewCharacterScreen) {
                    NewCharacterScreen(refreshID: $refreshID, viewModel: NewCharacterViewModel()) // Show new character screen for creating
                }
                .actionSheet(item: $viewModel.selectedActionSheet) { actionSheetType in
                    switch actionSheetType {
                    case .deleteMessages(let character):
                        return ActionSheet(
                            title: Text(""),
                            message: Text("All messages between you and \(character.name) will be deleted, but this character will still remain a contact."),
                            buttons: [
                                .destructive(Text("Delete"), action: {
                                    // Delete all messages belonging to character
                                    character.deleteAllMessages {
                                        // Trigger view update
                                        refreshID = UUID()
                                        // Save changes to core data
                                        PersistenceController.shared.saveContext()
                                    }
                                }),
                                .cancel(Text("Cancel"))
                            ]
                        )
                    case .deleteCharacter(let character):
                        return ActionSheet(
                            title: Text(""),
                            message: Text("\(character.name) will be deleted as a contact. All messages between you and them will also be deleted."),
                            buttons: [
                                .destructive(Text("Delete"), action: {
                                    // Delete character (associated messages are deleted thanks to the cascade property in Character Data Model)
                                    Constants.context.delete(character)
                                    // Trigger view update
                                    refreshID = UUID()
                                    // Save changes to core data
                                    PersistenceController.shared.saveContext()
                                }),
                                .cancel(Text("Cancel"))
                            ]
                        )
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingNewCharacterScreen = true // Show new character screen on button tap
                    }) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.title2)
                            .padding(.top, 8)
                            .dynamicTypeSize(.xSmall)
                    }
                }
            }
            .navigationTitle("Messages") // Set navigation title
            .onAppear {
                //Only on first screen setup
                if !hasPerformedInitialSetup {
                    //set has performedInitialSetup to true
                    hasPerformedInitialSetup = true
                    
                    //roll for a random new message from a character random character
                    if let randomCharacter = characters.randomElement() {
                        viewModel.rollForRandomNewMessage(from: randomCharacter) { success in
                            //if successfully received new message from character,
                            if success {
                                //refresh to update for unreadMessage blip
                                refreshID = UUID()
                            }
                        }
                    }
                    //only on re-appears, not on first launch
                } else {
                    //if needs to be refreshed, refresh screen
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                        if refreshManager.shouldRefresh {
                            refreshManager.shouldRefresh = false
                            refreshID = UUID()
                        }
                    }
                }
            }
            .alert(item: $persistenceController.persistenceError) { persistenceError in
                // Present an alert based on the error
                Alert(
                    title: Text("Error"),
                    message: Text(persistenceError.error.localizedDescription),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            if characters.isEmpty {
                viewModel.createDefaultCharactersIfNeeded()
            }
        }
        .id(refreshID) // Ensure view refreshes when refreshID changes
    }
    
    init(viewModel: HomeScreenViewModel, refreshManager: RefreshManager) {
        self.viewModel = viewModel
        self.refreshManager = refreshManager
    }
}


struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        return HomeScreen(viewModel: HomeScreenViewModel(), refreshManager: RefreshManager())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
