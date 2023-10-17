//
//  HomeScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI

//struct CharacterSwift: Identifiable {
//    var id = UUID()
//    var name = ""
//    //the prompt prefix goes at beginning of every prompt so the ai knows to act like this character before responding.
//    var promptPrefix = ""
//    var lastMessage = ""
//    var messages: NSSet = NSSet()
//    var lastMessaged: Date = Date()
//}

struct HomeScreen: View {
    
    // Enum for different action sheet types
    enum ActionSheetType: Identifiable {
        case deleteMessages(Character)
        case deleteCharacter(Character)
        
        var id: Int {
            // Generate a unique identifier for each case
            switch self {
            case .deleteMessages:
                return 1
            case .deleteCharacter:
                return 2
            }
        }
    }
    
    // MARK: - State Properties
    
    @State private var refreshID = UUID() // Unique identifier for view refreshing
    
    @State private var selectedActionSheet: ActionSheetType? // Selected action sheet type
    
    // Fetch characters using Core Data
    @FetchRequest(
        entity: Character.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.modified, ascending: false)]
    ) var characters: FetchedResults<Character>
    
    @State private var searchText = "" // Text for searching characters
    
    @State private var selectedCharacter: Character? = nil // Selected character for detailed view
    @State private var characterToEdit: Character? = nil // Character to edit
    
    @State private var showingNewCharacterScreen = false // Flag to show new character screen
    @State private var showingSearchResultsScreen = false // Flag to show search results screen
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar for filtering characters
                SearchBar(text: $searchText)
                    .onTapGesture {
                        showingSearchResultsScreen = true // Show search results screen on tap
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                
                List(characters) { character in
                    // List of characters with context menu
                    
                    Button(action: {
                        selectedCharacter = character // Select character for detailed view
                    }) {
                        CharacterRow(character: character) // Display character information
                    }
                    .contextMenu {
                        // Context menu options
                        
                        Button(action: {
                            characterToEdit = character // Edit character action
                        }) {
                            Text("Edit Character")
                            Image(systemName: "pencil")
                        }
                        
                        Button(action: {
                            selectedActionSheet = .deleteMessages(character) // Delete messages action
                        }) {
                            Text("Delete Messages")
                            Image(systemName: "trash")
                        }
                        
                        Button(action: {
                            selectedActionSheet = .deleteCharacter(character) // Delete character action
                        }) {
                            Text("Delete Character")
                            Image(systemName: "trash.fill")
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingSearchResultsScreen) {
                    SearchResultsScreen(refreshID: $refreshID) // Show search results screen
                }
                .fullScreenCover(item: $selectedCharacter) { character in
                    MessageScreen(refreshID: $refreshID, character: character, messages: character.sortedMessages) // Show message screen for selected character
                }
                .fullScreenCover(item: $characterToEdit) { character in
                    NewCharacterScreen(refreshID: $refreshID, character: character) // Show new character screen for editing
                }
                .sheet(isPresented: $showingNewCharacterScreen) {
                    NewCharacterScreen(refreshID: $refreshID) // Show new character screen for creating
                }
                .actionSheet(item: $selectedActionSheet) { actionSheetType in
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
                        showingNewCharacterScreen = true // Show new character screen on button tap
                    }) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.title2)
                            .padding(8)
                            .dynamicTypeSize(.xSmall)
                    }
                }
            }
            .navigationTitle("Message Hub") // Set navigation title
        }
        .id(refreshID) // Ensure view refreshes when refreshID changes
    }
}


struct HomeScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        
        return HomeScreen()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
