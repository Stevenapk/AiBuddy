//
//  EditContactIconView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct EditContactIconView: View {

    @ObservedObject var viewModel: NewCharacterViewModel
    
    @State private var showEditImageActionSheet = false
    
    @Binding var isKeyboardShowing: Bool

    var body: some View {
        Button {
            self.showEditImageActionSheet.toggle()
        } label: {
            EditContactIcon(contactImage: $viewModel.contactImage, name: $viewModel.name, isKeyboardShowing: $isKeyboardShowing)
        }
        // Action Sheet with options to select image, capture image, or remove current image
        .actionSheet(isPresented: $showEditImageActionSheet) {
            //Add button to select a picture from camera roll by default
            var buttons: [ActionSheet.Button] = [
                .default(Text("Camera Roll")) {
                    // Handle selecting from camera roll
                    viewModel.showPhotoLibrary = true
                },
                .cancel()
            ]

            //If the user's camera is available, add an option to capture a new image with camera
            if viewModel.isCameraAvailable() {
                buttons.insert(.default(Text("Camera"), action: {
                    // Handle taking a new photo
                    viewModel.showCapturePhoto = true
                }), at: 1)
            }

            // If there is a user-selected contact image, add option to remove it
            if viewModel.contactImage != nil {
                buttons.append(.default(Text("Remove Current Photo"), action: {
                    // Remove Current Photo from Contact Image
                    viewModel.contactImageData = nil
                    viewModel.contactImage = nil
                }))
            }
            return ActionSheet(title: Text("Select Image"), buttons: buttons)
        }
    }
}
