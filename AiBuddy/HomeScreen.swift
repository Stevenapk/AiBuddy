//
//  HomeScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI

import SwiftUI

struct HomeScreen: View {
    @State private var searchText = ""
    @State private var selectedCharacter: Character? = nil
    @State private var characters = [
        Character(name: "That 70's Guy", promptPrefix: "a 17 year old friend from the era of the 1970's who responds in slang and loves to go dancing and to the movies", lastMessage: "Hey dude, "),
        Character(name: "Selena Gomez", promptPrefix: "Selena Gomez", lastMessage: "Hey there, "),
        Character(name: "Motivational Speaker", promptPrefix: "a motivational speaker who does his best to inspire you when times are hard and when you need encouragement", lastMessage: "Hello! Remember, "),
        Character(name: "Licensed Therapist", promptPrefix: "a licensed therapist who specializes in helping people deal with emotional issues and moving forward by giving people assignments when they ask for them to improve their emotional health", lastMessage: "Hi! Let's work on ")
    ]

    var body: some View {
            NavigationView {
                VStack {
                    SearchBar(text: $searchText)
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
                }
                .navigationTitle("Message Hub")
                .fullScreenCover(item: $selectedCharacter) { character in
                    MessageScreen(character: character)
                }
            }
        }
}

struct CharacterRow: View {
    var character: Character
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                Text(String(character.name.prefix(1)).uppercased())
                    .foregroundColor(.white)
                    .font(.headline)
            }
            VStack(alignment: .leading) {
                Text(character.name)
                    .font(.headline)
                Text(character.lastMessage + "...")
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
        HomeScreen()
    }
}

struct Character: Identifiable {
    var id = UUID()
    var name = ""
    //the prompt prefix goes at beginning of every prompt so the ai knows to act like this character before responding.
    var promptPrefix = ""
    var lastMessage = ""
}
