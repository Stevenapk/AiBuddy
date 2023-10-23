//
//  HomeScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Combine
import CoreData

struct HomeScreen: View {
    
    @ObservedObject var viewModel: HomeScreenViewModel

    // MARK: - State Properties
    
    @State private var refreshID = UUID() // Unique identifier for view refreshing
    @State private var hasPerformedInitialSetup = false
    
    // Fetch characters using Core Data
    @FetchRequest(
        entity: Character.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.modified, ascending: false)]
    ) var characters: FetchedResults<Character>

    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar for filtering characters
                SearchBar(isTextFieldDisabled: true, text: $viewModel.searchText)
                    .onTapGesture {
                        viewModel.showingSearchResultsScreen = true // Show search results screen on tap
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                Divider()
                
                List(characters) { character in
                    // List of characters with context menu
                    
                    Button(action: {
                        viewModel.selectedCharacter = character // Select character for detailed view
                    }) {
                        CharacterRow(character: character) // Display character information
                    }
                    .contextMenu {
                        // Context menu options
                        
                        Button(action: {
                            viewModel.characterToEdit = character // Edit character action
                        }) {
                            Text("Edit Character")
                            Image(systemName: "pencil")
                        }
                        
                        Button(action: {
                            viewModel.selectedActionSheet = .deleteMessages(character) // Delete messages action
                        }) {
                            Text("Delete Messages")
                            Image(systemName: "trash")
                        }
                        
                        Button(action: {
                            viewModel.selectedActionSheet = .deleteCharacter(character) // Delete character action
                        }) {
                            Text("Delete Character")
                            Image(systemName: "trash.fill")
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Use .plain style
                .fullScreenCover(isPresented: $viewModel.showingSearchResultsScreen) {
                    SearchResultsScreen(refreshID: $refreshID, viewModel: SearchResultsViewModel()) // Show search results screen
                }
                .fullScreenCover(item: $viewModel.selectedCharacter) { character in
                    
                    // Initialize messageScreen's view model passing the character's sorted messages
                    let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                    
                    // Show the Message Screen for selected character
                    MessageScreen(viewModel: messageScreenViewModel, refreshID: $refreshID, character: character)
                }
                .fullScreenCover(item: $viewModel.characterToEdit) { character in
                    NewCharacterScreen(refreshID: $refreshID, character: character, viewModel: NewCharacterViewModel()) // Show new character screen for editing
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
//                    DispatchQueue.main.async { [self] in
//                        NotificationCenter.default.addObserver(self, selector: #selector(self.cloudKitSyncCompleted), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: PersistenceController.shared.container .persistentStoreCoordinator)
//                    }
                }
            }
        }
        .onAppear {
            if characters.isEmpty {
                viewModel.createDefaultCharactersIfNeeded()
            }
        }
        .id(refreshID) // Ensure view refreshes when refreshID changes
    }
    
    init(viewModel: HomeScreenViewModel) {
        
        self.viewModel = viewModel
        
        cancellable = NotificationCenter.default.publisher(for: NSNotification.Name.NSPersistentStoreRemoteChange)
            .sink { _ in
                print("CALLED: Core Data changes from CloudKit have been merged.")
                // Add your handling code here
            }
    }
    
    private var cancellable: AnyCancellable?
    @Environment(\.managedObjectContext) private var viewContext
    
}


struct HomeScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        
        return HomeScreen(viewModel: HomeScreenViewModel())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
