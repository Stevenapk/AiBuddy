//
//  NewCharacterScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/9/23.
//

import SwiftUI
import UIKit

class NewCharacterViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var aboutMe = ""
    @Published var contactImageData: Data?
    @Published var contactImage: UIImage?
    @Published var isNameRecognizable = false
    
    @Published var showEditImageActionSheet = false
    @Published var showPhotoLibrary = false
    @Published var showCapturePhoto = false

    func isValidForSave(existingCharacter: Character?) -> Bool {
        guard !name.isEmpty && name != "AI Buddy" else { return false }

        if let character = existingCharacter {
            if character.name != name || character.promptPrefix != aboutMe || character.isRecognizableName != isNameRecognizable || character.imgData != contactImageData {
                if isNameRecognizable || !aboutMe.isEmpty {
                    return true
                }
            }
        } else {
            if isNameRecognizable || !aboutMe.isEmpty {
                return true
            }
        }

        return false
    }

    func updateImage(_ image: UIImage?) {
        contactImage = image
    }
    
    func saveCharacter(existingCharacter: Character?, completion: @escaping (Bool) -> Void) {
        if let character = existingCharacter {
            // Overwriting previous character
            character.name = name
            character.promptPrefix = aboutMe
            character.isRecognizableName = isNameRecognizable
            
            // Create Image Object and assign character
            let imgData = ImageData(context: Constants.context)
            imgData.imageData = contactImageData
            imgData.character = character

            PersistenceController.shared.saveContext()
            
            completion(true) // Needs refresh
        } else {
            // Saving new character
            let newChar = Character(context: Constants.context)
            newChar.name = name
            newChar.promptPrefix = aboutMe
            newChar.isRecognizableName = isNameRecognizable
            
            // Create Image Object and assign character
            let imgData = ImageData(context: Constants.context)
            imgData.imageData = contactImageData
            imgData.character = newChar

            sendGreetingText(from: newChar, completion: { needsRefresh in
                completion(needsRefresh)
            })
        }
    }
    
    
//    func saveCharacter(existingCharacter: Character?) {
//        if let character = existingCharacter {
//            // Overwriting previous character
//            character.name = name
//            character.promptPrefix = aboutMe
//            character.isRecognizableName = isNameRecognizable
//
//            let imgData = ImageData(context: Constants.context)
//            imgData.imageData = contactImageData
//
//            character.imageData = imgData
//
//            PersistenceController.shared.saveContext()
//
//            refreshID = UUID()
//        } else {
//            // Saving new character
//            let newChar = Character(context: Constants.context)
//            newChar.name = name
//            newChar.promptPrefix = aboutMe
//            newChar.isRecognizableName = isNameRecognizable
//
//            let imgData = ImageData(context: Constants.context)
//            imgData.imageData = contactImageData
//
//            newChar.imageData = imgData
//
//            sendGreetingText(from: newChar)
//        }
//    }
    
    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func sendGreetingText(from newChar: Character, completion: @escaping (Bool) -> Void) {
        //define prompt from message text
        let messageText = "Greet me in a way unique to you"
        var prompt: String {
            if isNameRecognizable {
                if !aboutMe.isEmpty {
                    return "Act as \(name). Additionally, you are \(aboutMe). \(messageText)"
                } else {
                    return "Act as \(name). \(messageText)"
                }
            } else {
                if !aboutMe.isEmpty {
                    return "Act as \(aboutMe). If I ask, your name is \(name). \(messageText)"
                } else {
                    return "If I ask, your name is \(name). \(messageText)"
                }
            }
        }
        
        APIHandler.shared.getResponse(input: prompt, isAIBuddy: false) { result in
            switch result {
            case .success(let output):
                
                //format string output to remove empty first line
                let formattedOutput =  output.trimmingCharacters(in: .newlines)
                
                //create message object from string output
                let message = Message(context: Constants.context)
                message.content = formattedOutput
                message.set(newChar)
                
                //set character hasUnreadMessage to true
                newChar.hasUnreadMessage = true
                
                //save changes to core data
                PersistenceController.shared.saveContext()

                completion(true) // Indicates success
                
            case .failure(let error):
                print("RESPONSE failed: \(error)")
                completion(false) // Indicates failure
            }
        }
    }
    
    func prefillFields(for character: Character) {
            //set name
            name = character.name
            //set isFamousCharacter
            isNameRecognizable = character.isRecognizableName
            
            //set image if applicable
            if let image = character.image {
                contactImage = image
                contactImageData = character.imgData
            }
            aboutMe = character.promptPrefix
    }
    
}

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

struct NameTextField: View {
    @Binding var name: String

    var body: some View {
        TextField("Name", text: $name)
            .padding(7.5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
            )
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 5)
    }
}

struct AboutMeView: View {
    @Binding var aboutMe: String
    @Binding var isNameRecognizable: Bool
    @Binding var isKeyboardShowing: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(isNameRecognizable ? "About (Optional)" : "About (Required)")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    AboutTipsScreen()
                } label: {
                    Capsule()
                        .stroke(Color.blue, lineWidth: 1.5) // Outline with blue color
                        .overlay(
                            HStack(spacing: 2.5) {
                                Image(systemName: "info.circle")
                                Image(systemName: "chevron.right")
                            }
                        )
                        .frame(width: 50, height: 25)
                }
                
            }
            .padding(.horizontal)
            
            TextEditor(text: $aboutMe)
                .frame(height: 165)
                .animation(.easeInOut)
                .overlay(
                    Text("\(aboutMe.count)/350")
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .offset(y: -2.5)
                        .padding(.top, 4)
                        .padding(.horizontal, 6)
                        .font(Font.caption2)
                        .bold()
                        .background(Color.secondary
                            .cornerRadius(8))
                            .offset(x: -5, y: -5)
                        .opacity(aboutMe.isEmpty ? 0 : 1)
                    , alignment: .bottomTrailing)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
                .padding(.horizontal)
        }
        .onChange(of: aboutMe) { newText in
            if newText.count > 350 {
                aboutMe = String(newText.prefix(350))
            }
        }
    }
}

struct ToggleFamousCharacterView: View {
    @State private var showToggleInfoView = false
    @Binding var isNameRecognizable: Bool
    @Binding var name: String

    var body: some View {
        HStack {
            Toggle("Famous Character", isOn: $isNameRecognizable)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .padding(.trailing, 5)
            Button(action: {
                showToggleInfoView = true
            }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .offset(y: 1)
            }
            .alert(isPresented: $showToggleInfoView) {
                Alert(title: Text("Famous Character"), message: Text("If \(!name.isEmpty ? "\""+name+"\"" : "the name you entered") is a well-known person or character, such as Selena Gomez or Harry Potter, set this switch to ON. \n\nA good rule of thumb is if you can search them on google and they're in the top couple results, they are famous."), dismissButton: .default(Text("Okay")))
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

extension UIImage {
    
    var resizeToContactIconSize: UIImage? {
        let targetSize = CGSize(width: 240, height: 240) // Set target size

        // Begin a graphics context of the specified size
        UIGraphicsBeginImageContext(targetSize)
        
        // Ensure the context is properly cleaned up when exiting the block
        defer { UIGraphicsEndImageContext() }
        
        // Draw the current image into the specified rectangle
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        
        // Get the image from the current graphics context
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return resizedImage
    }
    
    var toCompressedData: Data? {
        // Attempt to create JPEG data with a compression quality of 50%
        guard let imageData = self.jpegData(compressionQuality: 0.5) else {
            // If creating the data fails, print an error message and return nil
            print("Error: Failed to create JPEG data.")
            return nil
        }
        
        // Calculate the size of the image data in kilobytes
        let sizeInKB = Double(imageData.count) / 1024.0
        print("Size of image data: \(sizeInKB) KB")
        
        // Check if the image is already below 100KB
        if sizeInKB < 100 {
            // If so, return the image data
            return imageData
        } else {
            // If the image is larger than 100KB, attempt further compression
            // Guard against infinite recursion by checking if size is very small
            guard sizeInKB > 1 else {
                print("Error: Image cannot be compressed further.")
                return nil
            }
            
            // Resize the image by half (scale of 0.5)
            let resizedImage = UIImage(data: imageData, scale: 0.5)
            // Attempt compression by recalling this same computed property (recursion)
            return resizedImage?.toCompressedData
        }
    }
    
//    var toCompressedData: Data? {
//
//        if let imageData = resizedImage.jpegData(compressionQuality: 0.5) {
//            let sizeInKB = Double(imageData.count) / 1024.0
//            print("Size of image data: \(sizeInKB) KB")
//
//            if sizeInKB < 100 {
//                return imageData
//            } else {
//                return resizedImage.toCompressedData
//            }
//        }
//        return nil
//    }
//
//    var toCompressedData: Data? {
//        guard let imageData = self.jpegData(compressionQuality: 0.5) else {
//            print("Error: Failed to create JPEG data.")
//            return nil
//        }
//
//        let sizeInKB = Double(imageData.count) / 1024.0
//        print("Size of image data: \(sizeInKB) KB")
//
//        if sizeInKB < 100 {
//            return imageData
//        } else {
//            // Guard against infinite recursion
//            guard sizeInKB > 1 else {
//                print("Error: Image cannot be compressed further.")
//                return nil
//            }
//
//            let resizedImage = UIImage(data: imageData, scale: 0.5)
//            return resizedImage?.toCompressedData
//        }
//    }
//    var toCompressedData: Data? {
//
//        if let imageData = self.jpegData(compressionQuality: 0.5) {
//                // imageData now contains JPEG data with a compression quality of 50%.
//
//                // Check the size of the imageData
//                let sizeInKB = Double(imageData.count) / 1024.0
//                print("Size of image data: \(sizeInKB) KB")
//
//                if sizeInKB < 100 {
//                    // The image is smaller than 100KB, you can use imageData as needed.
//                    return imageData
//                } else {
//                    // If the image is still too large, compress further
//                    return self.toCompressedData
//                }
//            }
//        return nil
//
//    }
}

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
                        .animation(.easeInOut)
                NameTextField(name: $viewModel.name)
                    .animation(.easeInOut)
                ToggleFamousCharacterView(isNameRecognizable: $viewModel.isNameRecognizable, name: $viewModel.name)
                    .animation(.easeInOut)
                AboutMeView(aboutMe: $viewModel.aboutMe, isNameRecognizable: $viewModel.isNameRecognizable, isKeyboardShowing: $isKeyboardShowing)
                    .animation(.easeInOut)
                Spacer()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                isKeyboardShowing = false
                print("Keyboard is hidden")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                isKeyboardShowing = true
                print("Keyboard is shown")
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

//struct NewCharacterScreen: View {
//
//    @Binding var refreshID: UUID
//
//    var character: Character?
//
//    @Environment(\.dismiss) var dismiss
//
//    @State private var showToggleInfoView = false
//    @State private var showAboutTipsScreen = false
//
//    @State private var name = ""
//    @State private var aboutMe = ""
//    @State private var contactImageData: Data?
//    @State private var contactImage: UIImage?
//    @State private var showEditImageActionSheet = false
//    @State private var showPhotoLibrary = false
//    @State private var showCapturePhoto = false
//    @State private var isNameRecognizable = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Button {
//                    self.showEditImageActionSheet = true
//                } label: {
//                    EditContactIcon(contactImage: $contactImage, name: $name)
//                }
//                .actionSheet(isPresented: $showEditImageActionSheet) {
//                    var buttons: [ActionSheet.Button] = [
//                        .default(Text("Camera Roll")) {
//                            // Handle selecting from camera roll
//                            showPhotoLibrary = true
//                        },
//                        .cancel()
//                    ]
//
//                    if isCameraAvailable() {
//                        buttons.insert(.default(Text("Camera"), action: {
//                            // Handle taking a new photo
//                            //                        self.selectPhoto(source: .camera)
//                            //                        ImagePickerView(image: self.$contactImage)
//                            showCapturePhoto = true
//                        }), at: 1)
//                    }
//
//                    if contactImage != nil {
//                        buttons.append(.default(Text("Remove Current Photo"), action: {
//                            // Remove Current Photo from Contact Image
//                            self.contactImageData = nil
//                            self.contactImage = nil
//                        }))
//                    }
//
//                    return ActionSheet(title: Text("Select Image"), buttons: buttons)
//                }
//
//                TextField("Name", text: $name)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
//                    .padding(.horizontal)
//                    .padding(.top)
//                    .padding(.bottom, 5)
//
//                HStack {
//                    Toggle("Famous Character", isOn: $isNameRecognizable)
//                        .toggleStyle(SwitchToggleStyle(tint: .green))
//                        .padding(.trailing, 5)
//                    Button(action: {
//                        showToggleInfoView = true
//                    }) {
//                        Image(systemName: "info.circle")
//                            .foregroundColor(.blue)
//                            .offset(y: 1)
//                    }
//                    .alert(isPresented: $showToggleInfoView) {
//                        Alert(title: Text("Famous Character"), message: Text("If \(!name.isEmpty ? "\""+name+"\"" : "the name you entered") is a well-known person or character, such as Selena Gomez or Harry Potter, set this switch to ON. \n\nA good rule of thumb is if you can search them on google and they're in the top couple results, they are famous."), dismissButton: .default(Text("Okay")))
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom)
//
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text(isNameRecognizable ? "About (Optional)" : "About (Required)")
//                            .font(.headline)
//                        Spacer()
//                        NavigationLink {
//                            AboutTipsScreen()
//                        } label: {
//                            Capsule()
//                                .stroke(Color.blue, lineWidth: 1.5) // Outline with blue color
//                                .overlay(
//                                    HStack(spacing: 2.5) {
//                                        Image(systemName: "info.circle")
//                                        Image(systemName: "chevron.right")
//                                    }
//                                )
//                                .frame(width: 50, height: 25)
//                        }
//
//                    }
//                    .padding(.horizontal)
//
//                    TextEditor(text: $aboutMe)
//                        .frame(height: 157.5)
//                        .overlay(
//                            Text("\(aboutMe.count)/350")
//                                .foregroundColor(aboutMe.count <= 350 ? .black : .red)
//                                .padding(.top, 4)
//                                .padding(.horizontal, 12)
//                                .font(Font.caption)
//                                .bold()
//                                .background(Color.white.opacity(0.7))
//                                .clipShape(RoundedRectangle(cornerRadius: 8))
//                                .offset(x: 0, y: -5)
//                                .opacity(aboutMe.isEmpty ? 0.5 : 1)
//                                .animation(.easeInOut)
//                            , alignment: .bottomTrailing)
//                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
//                        .padding(.horizontal)
//                }
//                Spacer()
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        // Dismiss Screen
//                        dismiss()
//                    }) {
//                        Text("Cancel")
//                    }
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        // Save character to core data
//                        saveCharacter()
//                        // Dismiss screen
//                        dismiss()
//                    }) {
//                        Text("Done")
//                    }
//                    .disabled(!isValidForSave())
//                }
//            }
//            .navigationTitle(character == nil ? "New Contact" : "Edit Contact")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//        .padding()
//        .onAppear {
//
//            //if editing, pre-fill fields
//            if let character {
//                name = character.name
//                isNameRecognizable = character.isRecognizableName
//
//                //set image if character image is not nil
//                if let image = character.image {
//                    contactImage = image
//                    contactImageData = character.imgData
//                }
//                aboutMe = character.promptPrefix
//                //if adding new character
//            }
//        }
//
//        .sheet(isPresented: $showPhotoLibrary) {
//            ImagePickerView(image: self.$contactImage, imageData: $contactImageData)
//        }
//        .sheet(isPresented: $showCapturePhoto) {
//            ImagePickerView(image: self.$contactImage, imageData: $contactImageData, sourceType: .camera)
//        }
//    }
//
//    func isValidForSave() -> Bool {
//        guard !name.isEmpty else { return false }
//
//        //if overwriting
//        if let character {
//            //if at least one element has changed
//            if character.name != name || character.promptPrefix != aboutMe || character.isRecognizableName != isNameRecognizable || character.imgData != contactImageData {
//                //if famous character and has name
//                if isNameRecognizable {
//                    return true
//                } else {
//                    //if not famous character but has name and about me
//                    if !aboutMe.isEmpty {
//                        return true
//                    }
//                }
//            }
//
//            //else if is new character save
//        } else {
//            //if famous character and has name
//            if isNameRecognizable {
//                return true
//            } else {
//                //if not famous character but has name and about me
//                if !aboutMe.isEmpty {
//                    return true
//                }
//            }
//        }
//
//        return false
//    }
//
//    func updateImage(_ image: UIImage?) {
//        contactImage = image
//    }
//
//    func saveCharacter() {
//
//        // Save character to Core Data
//
//        // if overwriting previous character
//        if character != nil {
//            character!.name = name
//            character!.promptPrefix = aboutMe
//            character!.isRecognizableName = isNameRecognizable
//            PersistenceController.shared.saveContext()
//
//            let imgData = ImageData(context: Constants.context)
//            imgData.imageData = contactImageData
//
//            character!.imageData = imgData
//
//            //refresh HomeScreen to reflect character change
//            refreshID = UUID()
//
//            //if saving new character
//        } else {
//            let newChar = Character(context: Constants.context)
//            newChar.name = name
//            newChar.promptPrefix = aboutMe
//            newChar.isRecognizableName = isNameRecognizable
//
//            let imgData = ImageData(context: Constants.context)
//            imgData.imageData = contactImageData
//
//            newChar.imageData = imgData
//
//            //Have their new character send a custom greeting text!
//            sendGreetingText(from: newChar)
//        }
//    }
//
//    func isCameraAvailable() -> Bool {
//        return UIImagePickerController.isSourceTypeAvailable(.camera)
//    }
//
//    func sendGreetingText(from newChar: Character) {
//        //define prompt from message text
//        let messageText = "Greet me in a way unique to you"
//        var prompt: String {
//            if isNameRecognizable {
//                if !aboutMe.isEmpty {
//                    return "Act as \(name). Additionally, you are \(aboutMe). \(messageText)"
//                } else {
//                    return "Act as \(name). \(messageText)"
//                }
//            } else {
//                if !aboutMe.isEmpty {
//                    return "Act as \(aboutMe). If I ask, your name is \(name). \(messageText)"
//                } else {
//                    return "If I ask, your name is \(name). \(messageText)"
//                }
//            }
//        }
//
//
//
//        APIHandler.shared.getResponse(input: prompt) { result in
//            switch result {
//            case .success(let output):
//
//                //format string output to remove empty first line
//                let formattedOutput =  output.trimmingCharacters(in: .newlines)
//
//                //create message object from string output
//                let message = Message(context: Constants.context)
//                message.content = formattedOutput
//                message.set(newChar)
//
//                //save changes to core data
//                PersistenceController.shared.saveContext()
//
//                //refresh HomeScreen to reflect new message in UI
//                refreshID = UUID()
//
//                self.dismiss()
//
//            case .failure(let error):
//                print("RESPONSE failed")
//            }
//        }
//    }
//}
    
