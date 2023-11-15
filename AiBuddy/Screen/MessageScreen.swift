//
//  MessageScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Combine
import CoreData

struct MessageScreen: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var persistenceController: PersistenceController
    
    @State private var hasPerformedInitialSetup = false
    @State private var keyboardDismissed = true
    
    @ObservedObject var viewModel: MessageScreenViewModel
    @ObservedObject var refreshManager: RefreshManager
    
    @Binding var refreshID: UUID

    var character: Character
    var messageIndexToScrollTo: Int?
    var unreadMessageCount: Int
    
    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            NavigationBar(character: character, refreshID: $refreshID, isTextFieldFocused: $viewModel.isTextFieldFocused, refreshManager: refreshManager, unreadMessageCount: unreadMessageCount)
                        
            // Message List
            MessageList(viewModel: viewModel, keyboardDismissed: $keyboardDismissed, messageIndexToScrollTo: messageIndexToScrollTo, character: character)
            
            Spacer()
 
            // Message Input Field
            MessageInputField(character: character, viewModel: viewModel, keyboardDismissed: $keyboardDismissed)

        }
        
        // Show alert if an error occurs on this screen (ex: AI failed to send response message)
        .alert(isPresented: $viewModel.showAlertMessage) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            // On only first screen setup
            if !hasPerformedInitialSetup {
                
                // Set hasPerformedInitialSetup to true
                hasPerformedInitialSetup = true
                
                // Unmark the unread message and save this change
                viewModel.unmarkUnreadMessage(for: character)
            }
        }
        .onReceive(Publishers.keyboardHeight) { height in
            viewModel.isTextFieldFocused = height > 0
        }
    }
}

struct MessageScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        // Set default random Binding<UUID> for preview
        let refreshID = Binding<UUID>(get: {
            return UUID()
        }, set: { newValue in
        })
        
        MessageScreen(viewModel: MessageScreenViewModel(messages: []), refreshManager: RefreshManager(), refreshID: refreshID, character: Character(context: Constants.context), unreadMessageCount: 0)
    }
}
