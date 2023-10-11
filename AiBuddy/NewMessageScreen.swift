//
//  NewMessageScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/9/23.
//

import SwiftUI

struct NewMessageScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var recipient = ""
    @State private var message = ""
    
    @State var showingNewCharacterScreen = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("To:", text: $recipient)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button {
                        //present add character screen
                        showingNewCharacterScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .padding(.trailing)
                    
                }
                .background(Color(.systemGray6))
                
                Divider()
                
                Spacer()
                
                HStack {
                    //                Spacer()
                    
                    TextField("", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .padding(.leading)
                    
                    Button(action: {
                        // Action when Send button is tapped
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                    .padding(.trailing, 16)
                }
            }
            .navigationBarTitle("New Message", displayMode: .inline)
        }
        .sheet(isPresented: $showingNewCharacterScreen) {
            NewCharacterScreen()
        }
        
    }
}

struct NewMessageScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageScreen()
//            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
