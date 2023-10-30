//
//  MessageScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Combine
import CoreData
//import Speech
//import AVFoundation

struct MessageScreen: View {
    
    @State private var hasPerformedInitialSetup = false
    
    @State private var keyboardDismissed = true
    
    @ObservedObject var viewModel: MessageScreenViewModel
    
//    @State var selectedMessage: Message? = nil
    @Binding var refreshID: UUID
//    @State private var isRecording = false
//
//    @Environment(\.dismiss) var dismiss
//

    var character: Character
    
    // Fetch Messages from Core Data and sort by timestamp
    //    @FetchRequest(
    //        entity: Message.entity(),
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)]
    //    ) var messages: FetchedResults<Message>
//
//    @State var messages: [Message]
    
    var messageIndexToScrollTo: Int?
    
//    @State private var models: [String] = []
//
//    @State private var messageText = ""
//    @State private var responseText = ""
//    @State private var isTextFieldFocused = false
//
//    @State private var textFieldHeight: CGFloat = 70

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            NavigationBar(character: character, refreshID: $refreshID, isTextFieldFocused: $viewModel.isTextFieldFocused)
                        
            // Message List
            MessageList(viewModel: viewModel, keyboardDismissed: $keyboardDismissed, messageIndexToScrollTo: messageIndexToScrollTo, character: character)
 
            // Message Input Field
            MessageInputField(character: character, viewModel: viewModel, keyboardDismissed: $keyboardDismissed)

        }
        .navigationBarHidden(true)
        .onAppear {
            //On only first screen setup
            if !hasPerformedInitialSetup {
                
                //set hasPerformedInitialSetup to true
                hasPerformedInitialSetup = true
                
                //unmark the unread message and save this change
                viewModel.unmarkUnreadMessage(for: character)
            }
        }
//        .padding(.bottom, isTextFieldFocused ? getKeyboardHeight() : 0)
//        .animation(.easeInOut(duration: 0.3))
        .onReceive(Publishers.keyboardHeight) { height in
            viewModel.isTextFieldFocused = height > 0
        }
//        .keyboardAdaptive() // Automatically adjust view position for keyboard
    }
    
}

struct MessageScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let refreshID = Binding<UUID>(get: {
            // Return your initial value here
            return UUID()
        }, set: { newValue in
            // Handle the updated value here
        })
        
        MessageScreen(viewModel: MessageScreenViewModel(messages: []), refreshID: refreshID, character: Character(context: Constants.context))
    }
}
