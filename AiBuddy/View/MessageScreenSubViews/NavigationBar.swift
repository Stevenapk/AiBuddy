//
//  NavigationBar.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/17/23.
//

import SwiftUI

struct NavigationBar: View {
    
    @State var character: Character
    @Binding var refreshID: UUID
    @Binding var isTextFieldFocused: Bool
    @ObservedObject var refreshManager: RefreshManager
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            Button(action: {
                // Handle back button action
                // Refresh HomeScreen for most recent message preview
//                refreshID = UUID()
                refreshManager.shouldRefresh = true
                // Set the text field to not be focused
//                isTextFieldFocused = false
                // Dismiss back to previous screen
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .offset(y: -12.5)
                    .font(.system(size: 23))
                    .bold()
                    .frame(width: 20, height: 50)
            }
            Spacer()
            VStack(spacing: 0) {
                ContactIcon(character: $character, width: 50)
                Text(character.name)
                    .font(.caption2)
                    .padding(4)
            }
            .offset(x:-10)
            Spacer()
            EmptyView() // Add a placeholder for any additional buttons/icons
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(.systemGray6))
    }
}


struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        
        let refreshID = Binding<UUID>(get: {
            // Return your initial value here
            return UUID()
        }, set: { newValue in
            // Handle the updated value here
        })
        
        MessageScreen(viewModel: MessageScreenViewModel(messages: []), refreshManager: RefreshManager(), refreshID: refreshID, character: Character(context: PersistenceController.shared.container.viewContext))
    }
}
