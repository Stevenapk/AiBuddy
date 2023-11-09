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
        .actionSheet(isPresented: $showEditImageActionSheet) {
            var buttons: [ActionSheet.Button] = [
                .default(Text("Camera Roll")) {
                    // Handle selecting from camera roll
                    viewModel.showPhotoLibrary = true
                },
                .cancel()
            ]

            if viewModel.isCameraAvailable() {
                buttons.insert(.default(Text("Camera"), action: {
                    // Handle taking a new photo
                    viewModel.showCapturePhoto = true
                }), at: 1)
            }

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
