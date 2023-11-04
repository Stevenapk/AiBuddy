//
//  SearchResultsScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/10/23.
//

import SwiftUI

extension String {
    
    func highlighted(letters: String) -> AttributedString {
        
        //convert original string to NSMutableAttributedString
        let highlightedString = NSMutableAttributedString(string: self)
        
        //set original gray color
        let entireRange = NSRange(location: 0, length: highlightedString.length)
        highlightedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: entireRange)
        
        //highlight in black the letters which were searched
        let range = self.range(of: letters, options: .caseInsensitive)
        if range != nil {
            highlightedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(range!, in: self))
        }

        //Return AttributedString for use in Text()
        return AttributedString(highlightedString)
    }
    
}

class SearchResultsViewModel: ObservableObject {

    @Published var searchText = ""
    @Published var selectedCharacter: Character? = nil
    @Published var selectedMessage: Message? = nil

}

struct SearchBarView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SearchResultsViewModel
    @FocusState var showKeyboard: Bool

    var body: some View {
        HStack {
            SearchBar(text: $viewModel.searchText, showKeyboard: _showKeyboard)

            Button("Cancel") {
                // Dismiss to HomeScreen
                dismiss()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
    }
}

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
    //                .onTapGesture {
    //                    selectedMessage = message
    //                }
            }
        }
        .listStyle(PlainListStyle()) // Use .plain style
    }
}

struct SearchResultsScreen: View {
    
    @Binding var refreshID: UUID
    
    @State private var hasPerformedInitialSetup = false
    
    @FocusState var showKeyboard: Bool
    
    @ObservedObject var viewModel: SearchResultsViewModel
    @ObservedObject var refreshManager: RefreshManager
    
    @FetchRequest(
        entity: Message.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: false)]
    ) var messages: FetchedResults<Message>
    
    @FetchRequest(
        entity: Character.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.modified, ascending: false)]
    ) var characters: FetchedResults<Character>
    
    var unreadMessageCount: Int
    
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
                        // Handle tap here
                        print("Spacer tapped")
                    }
                }
                Divider()
    //                .fullScreenCover(item: $viewModel.selectedCharacter) { character in
    //
    //                    // Initialize message screen's view model
    //                    let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
    //
    //                    MessageScreen(viewModel: messageScreenViewModel, refreshID: $refreshID, character: character)
    //                }
//                    .fullScreenCover(item: $viewModel.selectedMessage) { message in
//                        let character = message.character
//                        let messages = character.sortedMessages
//                        let indexToScrollTo = messages.firstIndex(of: message)
//
//                        // Initialize message screen's view model
//                        let messageScreenViewModel = MessageScreenViewModel(messages: messages)
//
//                        //present message screen passing optional index variable
//                        MessageScreen(
//                            viewModel: messageScreenViewModel, refreshID: $refreshID, character: character,
//                            messageIndexToScrollTo: indexToScrollTo
//                        )
//                    }
            } 
        .navigationBarHidden(true)
        .onAppear {
            if !hasPerformedInitialSetup {
                hasPerformedInitialSetup = true
                // Automatically open the keyboard when the view appears
                print("APPEARING")
                showKeyboard = true
//                DispatchQueue.main.async {
//                    UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
//                }
            }
        }
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
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
                Text(message.content.highlighted(letters: lettersToHighlight))
                    .font(.system(size: 15))
            }
        }
    }
}


struct ContactIconsRow: View {
    
    var characters: FetchedResults<Character>
    var unreadMessageCount: Int
    
    @Binding var searchText: String
    
    @Binding var refreshID: UUID
    @ObservedObject var refreshManager: RefreshManager
    
    let diameter = (UIScreen.main.bounds.width-160) / 4
    
//    var onTapCharacter: (Character) -> Void //define a callback
    
    var body: some View {
        
        let filteredCharacters = characters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            HStack(spacing: 30) {
                
                if !filteredCharacters.isEmpty {
                    
                    ForEach(filteredCharacters.prefix(4), id: \.id) { character in
                        
                        NavigationLink {
                            // Initialize message screen's view model
                            let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                            
                            MessageScreen(viewModel: messageScreenViewModel, refreshManager: refreshManager, refreshID: $refreshID, character: character, unreadMessageCount: unreadMessageCount)
                        } label: {
                            VStack {
                                Circle()
                                    .foregroundColor(character.colorForFirstInitial) // Adjust color as needed
                                    .frame(width: diameter)
                                    .overlay(Text(character.firstInitial).foregroundColor(.white))
                                Text(character.name.highlighted(letters: searchText))
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .frame(maxWidth: diameter)
                            }
    //                        .onTapGesture {
    //                            //trigger callback
    //                            onTapCharacter(character)
    //                        }
                        }

                        

                    }
                    .padding(.vertical)
                } else {
                    ForEach(characters.prefix(4), id: \.id) { character in
                        NavigationLink {
                            // Initialize message screen's view model
                            let messageScreenViewModel = MessageScreenViewModel(messages: character.sortedMessages)
                            
                            MessageScreen(viewModel: messageScreenViewModel, refreshManager: refreshManager, refreshID: $refreshID, character: character, unreadMessageCount: unreadMessageCount)
                        } label: {
                            VStack {
                                Circle()
                                    .foregroundColor(character.colorForFirstInitial) // Adjust color as needed
                                    .frame(width: diameter)
                                    .overlay(Text(character.firstInitial).foregroundColor(.white))
                                Text(character.name)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .frame(maxWidth: diameter)
                                    .foregroundColor(.primary)
                            }
    //                        .onTapGesture {
    //                            //trigger callback
    //                            onTapCharacter(character)
    //                        }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding(.horizontal, 30)
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
        return SearchResultsScreen(refreshID: refreshID, viewModel: SearchResultsViewModel(), refreshManager: RefreshManager(), unreadMessageCount: 0)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
