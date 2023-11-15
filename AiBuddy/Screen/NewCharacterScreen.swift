//
//  NewCharacterScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/9/23.
//

import SwiftUI
import UIKit

struct NewCharacterScreen: View {
    
    @State private var hasPerformedInitialSetup = false
    
    @Binding var refreshID: UUID
    var character: Character?

    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: NewCharacterViewModel
    
    @State var isKeyboardShowing: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                EditContactIconView(viewModel: viewModel, isKeyboardShowing: $isKeyboardShowing)
                NameTextField(name: $viewModel.name)
                ToggleFamousCharacterView(isNameRecognizable: $viewModel.isNameRecognizable, name: $viewModel.name)
                AboutMeView(aboutMe: $viewModel.aboutMe, isNameRecognizable: $viewModel.isNameRecognizable, isKeyboardShowing: $isKeyboardShowing)
                Spacer()
            }
            .animation(.easeInOut, value: isKeyboardShowing)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                isKeyboardShowing = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                isKeyboardShowing = true
            }
            //Cancel Toolbar Item
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Dismiss Screen
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
            //Save Toolbar Item
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Save character to core data
                        viewModel.saveCharacter(existingCharacter: character, completion: { needsRefresh in
                            // If the homescreen needs to be refreshed because of specific changed data,
                            if needsRefresh {
                                // Trigger a refresh
                                refreshID = UUID()
                            }
                        })
                        // Dismiss screen
                        dismiss()
                    }) {
                        Text("Done")
                    }
                    // Disable the done button if save conditions are not met
                    .disabled(!viewModel.isValidForSave(existingCharacter: character))
                }
            }
            // Switch navigation title depending on if the user is creating a new contact or editing a previous one
            .navigationTitle(character == nil ? "New Contact" : "Edit Contact")
            // Make the navigation bar title smaller and centered at the top
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding(.horizontal)
        .padding(.top)
        .onAppear {
            if !hasPerformedInitialSetup {
                
                //set has performedInitialSetup to true
                hasPerformedInitialSetup = true
                
                //Prefill fields if overwriting previous character
                if let character {
                    viewModel.prefillFields(for: character)
                }
            }
        }
        //present Show Photo library sheet when toggled
        .sheet(isPresented: $viewModel.showPhotoLibrary) {
            ImagePickerView(image: self.$viewModel.contactImage, imageData: $viewModel.contactImageData)
        }
        //present Show Capture Photo sheet when toggled
        .sheet(isPresented: $viewModel.showCapturePhoto) {
            ImagePickerView(image: self.$viewModel.contactImage, imageData: $viewModel.contactImageData, sourceType: .camera)
        }
    }
           
        
    
}

struct NewCharacterScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let refreshID = Binding<UUID>(get: {
                // Set random UUID as initial value
                return UUID()
            }, set: { newValue in
                // Handle the updated value here
            })
            NewCharacterScreen(refreshID: refreshID, viewModel: NewCharacterViewModel())
        }
    }
}
