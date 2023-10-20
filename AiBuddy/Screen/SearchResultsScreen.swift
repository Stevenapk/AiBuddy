//
//  SearchResultsScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/10/23.
//

import SwiftUI

class SearchResultsViewModel: ObservableObject {

    @Published var searchText = ""
    @Published var selectedCharacter: Character? = nil
    @Published var selectedMessage: Message? = nil

}

struct SearchBarView: View {
    @ObservedObject var viewModel: SearchResultsViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            TextField("Search", text: $viewModel.searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Button("Cancel") {
                print("SHOULD DISMISS PARENT VIEW")
                //Remove Keyboard from view
                UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                // Dismiss view
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}

struct MessageSearchResultsList: View {
    var messages: FetchedResults<Message>
    @Binding var searchText: String
    @Binding var selectedMessage: Message?
    
    var body: some View {
        // Use Core Data fetch request to filter messages
        // Iterate through results and display CharacterRow for each
        List(messages.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }) { message in
            MessageRow(message: message, lettersToHighlight: searchText) { message in
                selectedMessage = message
            }
        }
    }
}

struct ContactIconsOrMessageSearchResultsView: View {
    @Binding var searchText: String
    @Binding var selectedCharacter: Character?
    @Binding var selectedMessage: Message?

    var characters: FetchedResults<Character>
    var messages: FetchedResults<Message>

    var body: some View {
        if searchText.isEmpty {
            // Display four contact icons
            ContactIconsRow(characters: characters, searchText: $searchText, onTapCharacter: { character in
                selectedCharacter = character
            })
            Divider()
        } else {
            // Display filtered messages list
            // Use Core Data fetch request to filter messages
            // Iterate through results and display CharacterRow for each
            MessageSearchResultsList(messages: messages, searchText: $searchText, selectedMessage: $selectedMessage)
        }
    }
}


struct SearchResultsScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var refreshID: UUID
    
    @State private var hasPerformedInitialSetup = false
    
    @ObservedObject var viewModel: SearchResultsViewModel
    
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
            
            SearchBarView(viewModel: viewModel)
            Divider()
            // Display four contact icons
            ContactIconsRow(characters: characters, searchText: $viewModel.searchText, onTapCharacter: { character in
                viewModel.selectedCharacter = character
            })
            Divider()
            // If there is typed in search text
            if !viewModel.searchText.isEmpty {
                // Display filtered messages list
                MessageSearchResultsList(messages: messages, searchText: $viewModel.searchText, selectedMessage: $viewModel.selectedMessage)
            }
            Spacer()
                .fullScreenCover(item: $viewModel.selectedCharacter) { character in
                    
                    // Initialize message screen's view model
                    let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                    
                    MessageScreen(viewModel: messageScreenViewModel, refreshID: $refreshID, character: character)
                }
                .fullScreenCover(item: $viewModel.selectedMessage) { message in
                    let character = message.character
                    let messages = character.sortedMessages
                    let indexToScrollTo = messages.firstIndex(of: message)
                    
                    // Initialize message screen's view model
                    let messageScreenViewModel = MessageScreenViewModel(messages: messages)
                    
                    //present message screen passing optional index variable
                    MessageScreen(
                        viewModel: messageScreenViewModel, refreshID: $refreshID, character: character,
                        messageIndexToScrollTo: indexToScrollTo
                    )
                }
        }
        .navigationBarHidden(true)
        .onTapGesture {
                    // Resign first responder (dismiss keyboard) when tapped outside of the text field
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        .onAppear {
            if !hasPerformedInitialSetup {
                hasPerformedInitialSetup = true
                // Automatically open the keyboard when the view appears
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
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
            highlightedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(range!, in: originalString))
        }

        //Return AttributedString for use in Text()
        return AttributedString(highlightedString)
    }
}


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
        let refreshID = Binding<UUID>(get: {
                    // Return your initial value here
                    return UUID()
                }, set: { newValue in
                    // Handle the updated value here
                })
        return SearchResultsScreen(refreshID: refreshID, viewModel: SearchResultsViewModel())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
