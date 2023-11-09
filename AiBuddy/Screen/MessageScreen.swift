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
    
    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject var alertManager: ErrorAlertManager
    
    @State private var hasPerformedInitialSetup = false
    @State private var keyboardDismissed = true
    
    @ObservedObject var viewModel: MessageScreenViewModel
    @ObservedObject var refreshManager: RefreshManager
    @Binding var refreshID: UUID

    var character: Character
    
    // Fetch Messages from Core Data and sort by timestamp
    //    @FetchRequest(
    //        entity: Message.entity(),
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)]
    //    ) var messages: FetchedResults<Message>
//
//    @State var messages: [Message]
    
    var messageIndexToScrollTo: Int?
    var unreadMessageCount: Int

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
        .alert(isPresented: $alertManager.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertManager.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(item: $persistenceController.saveError) { saveError in
            // Present an alert based on the error
            Alert(
                title: Text("Error"),
                message: Text(saveError.error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
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
        .onReceive(Publishers.keyboardHeight) { height in
            viewModel.isTextFieldFocused = height > 0
        }
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
        
        MessageScreen(viewModel: MessageScreenViewModel(messages: []), refreshManager: RefreshManager(), refreshID: refreshID, character: Character(context: Constants.context), unreadMessageCount: 0)
    }
}
