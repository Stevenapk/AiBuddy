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
    
    @FetchRequest(
        entity: Character.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.modified, ascending: false)]
    ) var characters: FetchedResults<Character>
    
    @State private var searchText = ""
    @State private var selectedCharacter: Character? = nil
    
    @State private var showingNewMessageScreen = false
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
                        .padding()
                    
                    List(characters
//                        .filter {
//                        $0.name.localizedCaseInsensitiveContains(searchText) ||
//                        $0.promptPrefix.localizedCaseInsensitiveContains(searchText)
//                    }
                    ) { character in
                        Button(action: {
                            selectedCharacter = character
                        }) {
                            CharacterRow(character: character)
                        }
                    }
                    .fullScreenCover(isPresented: $showingSearchResultsScreen) {
                        SearchResultsScreen()
                    }
                    .fullScreenCover(item: $selectedCharacter) { character in
                        MessageScreen(character: character, messages: character.sortedMessages)
                    }
                    .sheet(isPresented: $showingNewMessageScreen) {
                        NewMessageScreen()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Present AddMessageScreen
                            showingNewMessageScreen = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.title2)
                                .padding(8)
                            
                        }
                    }
                }
                .navigationTitle("Message Hub")
            }
        }
}

struct CharacterRow: View {
    var character: Character
    
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
                Text(character.name)
                    .font(.headline)
                Text(character.lastText + "...")
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
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
