//
//  SearchResultsScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/10/23.
//

import SwiftUI

struct SearchResultsScreen: View {
    
    @State var selectedCharacter: Character? = nil
    @State var selectedMessage: Message? = nil
    
    @State var searchText: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        entity: Message.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: false)]
    ) var messages: FetchedResults<Message>
    
    @FetchRequest(
        entity: Character.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.modified, ascending: false)]
    ) var characters: FetchedResults<Character>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            Divider()
            
            if searchText.isEmpty {
                // Display four contact icons
                ContactIconsRow(characters: characters, searchText: $searchText, onTapCharacter: { character in
                    self.selectedCharacter = character
                })
                Divider()
            } else {
                // Display four contact icons
                ContactIconsRow(characters: characters, searchText: $searchText, onTapCharacter: { character in
                    self.selectedCharacter = character
                })
                Divider()
                // Display filtered messages list
                // Use Core Data fetch request to filter messages
                // Iterate through results and display CharacterRow for each
                List(messages.filter {
                    $0.content.localizedCaseInsensitiveContains(searchText)
                }) { message in
                    MessageRow(message: message, lettersToHighlight: searchText) { message in
                        self.selectedMessage = message
                    }
                }
                
            }
            Spacer()
                .fullScreenCover(item: $selectedCharacter) { character in
                    MessageScreen(character: character, messages: character.sortedMessages)
//                        .transition(.move(edge: .trailing))
                }
                .fullScreenCover(item: $selectedMessage) { message in
                    let character = message.character
                    let messages = character.sortedMessages
                    let indexToScrollTo = messages.firstIndex(of: message)
                    
                    //present message screen passing optional index variable
                    MessageScreen(
                        character: character,
                        messages: messages,
                        messageIndexToScrollTo: indexToScrollTo
                    )
                }
        }
        .navigationBarHidden(true)
    }
}

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}

struct MessageRow: View {
    
    var message: Message
    var lettersToHighlight: String
    var onTapMessage: (Message) -> Void //define a callback
    
    var body: some View {
        HStack {
            //display letters if they have no contact image, but have a name
            if message.character.image == nil && !message.character.name.isEmpty {
                ZStack {
                    Circle()
                        .foregroundColor(message.character.colorForFirstInitial)
                        .frame(width: 50, height: 50)
                    Text(message.character.firstInitial)
                        .foregroundColor(.white)
                        .font(.headline)
                }
            } else {
                Image(uiImage: message.character.image ?? UIImage(systemName: "person.crop.circle")!)
                    .resizable()
                    .frame(width: 52.375, height: 52.375)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text(message.character.name)
                    .font(.headline)
                Text(partiallyHighlightedString(message.content))
                    .font(.caption)
            }
        }
        .onTapGesture {
            //trigger callback
            onTapMessage(message)
        }
    }
    
    func partiallyHighlightedString(_ originalString: String) -> AttributedString {
        
        //convert original string to NSMutableAttributedString
        let highlightedString = NSMutableAttributedString(string: originalString)
        
        //set original gray color
        let entireRange = NSRange(location: 0, length: highlightedString.length)
        highlightedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: entireRange)
        
        //highlight in black the letters which were searched
        let range = originalString.range(of: lettersToHighlight, options: .caseInsensitive)
        if range != nil {
            highlightedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(range!, in: originalString))
        }

        //Return AttributedString for use in Text()
        return AttributedString(highlightedString)
    }
}

//struct HighlightedText: View {
//    var messageContent: String
//    var lettersToHighlight: String
//
//    var body: some View {
//        let highlightedText = messageContent.map { char -> Text in
//            if lettersToHighlight.lowercased().contains(char.lowercased()) {
//                return Text(String(char)).foregroundColor(.black)
//            } else {
//                return Text(String(char)).foregroundColor(.secondary)
//            }
//        }
//        return HStack {
//            ForEach(0..<highlightedText.count, id: \.self) { index in
//                highlightedText[index]
//            }
//        }
//    }
//}

//struct HighlightedText: ViewModifier {
//    var messageContent: String
//    var lettersToHighlight: String
//
//    func body(content: Content) -> some View {
//
//        let originalString = messageContent
//        let highlightedString = NSMutableAttributedString(string: originalString)
//
//        let range = originalString.range(of: lettersToHighlight, options: .caseInsensitive)
//        if range != nil {
//            highlightedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(range!, in: originalString))
//        }
//
//        return Text(AttributedString(highlightedString))
//    }
//}
//
//extension View {
//    func highlight(messageContent: String, lettersToHighlight: String) -> some View {
//        self.modifier(HighlightedText(messageContent: messageContent, lettersToHighlight: lettersToHighlight))
//    }
//}


//struct ContactIconsRow: View {
//    var body: some View {
//        HStack(spacing: 20) {
//            ForEach(0..<4, id: \.self) { _ in
//                VStack {
//                    Circle()
//                        .foregroundColor(Color.blue) // Adjust color as needed
//                        .frame(width: 60, height: 60)
//                    Text("Name")
//                        .font(.caption)
//                }
//            }
//            .padding()
//        }
//    }
//}

struct ContactIconsRow: View {
    
    var characters: FetchedResults<Character>
    
    @Binding var searchText: String
    
    let diameter = (UIScreen.main.bounds.width-100) / 4
    
    var onTapCharacter: (Character) -> Void //define a callback
    
    var body: some View {
        
        let filteredCharacters = characters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            HStack(spacing: 20) {
                
                if !filteredCharacters.isEmpty {
                    
                    ForEach(filteredCharacters.prefix(4), id: \.id) { character in
                        VStack {
                            Circle()
                                .foregroundColor(Color.blue) // Adjust color as needed
                                .frame(width: diameter)
                                .overlay(Text(character.firstInitial).foregroundColor(.white))
                            Text(partiallyHighlightedString(character.name))
                                .font(.caption2)
                                .lineLimit(1)
                                .frame(maxWidth: diameter)
                        }
                        .onTapGesture {
                            //trigger callback
                            onTapCharacter(character)
                        }
                    }
                    .padding(.vertical)
                } else {
                    ForEach(characters.prefix(4), id: \.id) { character in
                        VStack {
                            Circle()
                                .foregroundColor(Color.blue) // Adjust color as needed
                                .frame(width: diameter)
                                .overlay(Text(character.firstInitial).foregroundColor(.white))
                            Text(character.name)
                                .font(.caption2)
                                .lineLimit(1)
                                .frame(maxWidth: diameter)
                        }
                        .onTapGesture {
                            //trigger callback
                            onTapCharacter(character)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding()
    }
    
    func partiallyHighlightedString(_ originalString: String) -> AttributedString {
        
        //convert original string to NSMutableAttributedString
        let highlightedString = NSMutableAttributedString(string: originalString)
        
        //set original gray color
        let entireRange = NSRange(location: 0, length: highlightedString.length)
        highlightedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: entireRange)
        
        //highlight in black the letters which were searched
        let range = originalString.range(of: searchText, options: .caseInsensitive)
        if range != nil {
            highlightedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(range!, in: originalString))
        }

        //Return AttributedString for use in Text()
        return AttributedString(highlightedString)
    }
}


struct SearchResultsScreen_Previews: PreviewProvider {
    static var previews: some View {
        return SearchResultsScreen()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
