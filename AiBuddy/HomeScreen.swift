//
//  HomeScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI

struct CharacterSwift: Identifiable {
    var id = UUID()
    var name = ""
    //the prompt prefix goes at beginning of every prompt so the ai knows to act like this character before responding.
    var promptPrefix = ""
    var lastMessage = ""
    var messages: NSSet = NSSet()
    var lastMessaged: Date = Date()
}

struct HomeScreen: View {
    
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
    
    @State private var refreshID = UUID()
    
    @State private var selectedActionSheet: ActionSheetType?
    
    @FetchRequest(
        entity: Character.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.modified, ascending: false)]
    ) var characters: FetchedResults<Character>
    
    @State private var searchText = ""
    @State private var selectedCharacter: Character? = nil
    @State private var characterToEdit: Character? = nil
    @State private var showingNewCharacterScreen = false
    @State private var showingSearchResultsScreen = false
    
    //    @State private var characters = [
    //        CharacterSwift(name: "That 70's Guy", promptPrefix: "a 17 year old friend from the era of the 1970's who responds in slang and loves to go dancing and to the movies", lastMessage: "Hey dude, "),
    //        CharacterSwift(name: "Selena Gomez", promptPrefix: "Selena Gomez", lastMessage: "Hey there, "),
    //        CharacterSwift(name: "Motivational Speaker", promptPrefix: "a motivational speaker who does his best to inspire you when times are hard and when you need encouragement", lastMessage: "Hello! Remember, "),
    //        CharacterSwift(name: "Licensed Therapist", promptPrefix: "a licensed therapist who specializes in helping people deal with emotional issues and moving forward by giving people assignments when they ask for them to improve their emotional health", lastMessage: "Hi! Let's work on ")
    //    ]
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .onTapGesture {
                        //present search screen
                        showingSearchResultsScreen = true
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                
                List(characters
                ) { character in
                    Button(action: {
                        selectedCharacter = character
                    }) {
                        CharacterRow(character: character)
                    }
                    .contextMenu {
                        Button(action: {
                            // Edit character action
                            characterToEdit = character
                        }) {
                            Text("Edit Character")
                            Image(systemName: "pencil")
                        }
                        
                        Button(action: {
                            // Delete all messages action
                            selectedActionSheet = .deleteMessages(character)
                        }) {
                            Text("Delete Messages")
                            Image(systemName: "trash")
                        }
                        
                        Button(action: {
                            // Delete character action
                            selectedActionSheet = .deleteCharacter(character)
                        }) {
                            Text("Delete Character")
                            Image(systemName: "trash.fill")
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingSearchResultsScreen) {
                    SearchResultsScreen(refreshID: $refreshID)
                }
                .fullScreenCover(item: $selectedCharacter) { character in
                    MessageScreen(refreshID: $refreshID, character: character, messages: character.sortedMessages)
                }
                .fullScreenCover(item: $characterToEdit) { character in
                    NewCharacterScreen(refreshID: $refreshID, character: character)
                }
                .sheet(isPresented: $showingNewCharacterScreen) {
                    NewCharacterScreen(refreshID: $refreshID)
                }
                .actionSheet(item: $selectedActionSheet) { actionSheetType in
                    switch actionSheetType {
                    case .deleteMessages(let character):
                        return ActionSheet(
                            title: Text(""),
                            message: Text("All messages between you and \(character.name) will be deleted, but this character will still remain a contact."),
                            buttons: [
                                .destructive(Text("Delete"), action: {
                                    
                                    // Delete all messages associated with the character
                                    //                                        for message in character.sortedMessages {
                                    //                                            Constants.context.delete(message)
                                    //                                        }
                                    if character.messages != nil {
                                        for message in character.messages! {
                                            let message = message as! Message
                                            Constants.context.delete(message)
                                        }
                                        character.lastText = ""
                                        //                                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                        refreshID = UUID() // Trigger view update
                                        //                                            }
                                    }
                                    
                                    // Save changes to core data
                                    PersistenceController.shared.saveContext()
                                    
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
                                    
                                    // Delete character (all associated messages are deleted thanks to the cascade property in Character Data Model)
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
                        // Present AddMessageScreen
                        showingNewCharacterScreen = true
                    }) {
                        //                            Image(systemName: "square.and.pencil")
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.title2)
                            .padding(8)
                            .dynamicTypeSize(.xSmall)
                        
                    }
                }
            }
            .navigationTitle("Message Hub")
        }
        //ensures the refresh of this view when the refreshId is changed
        .id(refreshID)
    }
}

struct CharacterRow: View {
    @State var character: Character
    
    var body: some View {
        HStack {
            //display letters if they have no contact image, but have a name
            if character.image == nil && !character.name.isEmpty {
                ZStack {
                    Circle()
                        .foregroundColor(character.colorForFirstInitial)
                        .frame(width: 50, height: 50)
                    Text(character.firstInitial)
                        .foregroundColor(.white)
                        .font(.headline)
                }
            } else {
                Image(uiImage: character.image ?? UIImage(systemName: "person.crop.circle")!)
                    .resizable()
                    .frame(width: 52.375, height: 52.375)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(character.name)
                        .font(.headline)
                    Spacer()
                    Text(character.modified.formattedString)
                        .font(.caption)
                }
                Text(character.lastText)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .lineLimit(2)
                Spacer()
            }
            .padding(.top, 5)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search", text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}


struct HomeScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        
        return HomeScreen()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
