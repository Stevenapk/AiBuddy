//
//  NewCharacterScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/9/23.
//

import SwiftUI
import UIKit

struct NewCharacterScreen: View {
    
    @Binding var refreshID: UUID
    
    var character: Character?
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showToggleInfoView = false
    @State private var showAboutTipsScreen = false
    
    @State private var name = ""
    @State private var aboutMe = ""
    @State private var contactImage: UIImage? {
        didSet {
            if contactImage != nil {
                showEditButton = true
            } else {
                showEditButton = false
            }
        }
    }
    @State private var showImagePicker = false
    @State private var showPhotoLibrary = false
    @State private var showCapturePhoto = false
    @State private var showEditButton = true
    @State private var isNameRecognizable = false
    
    var firstInitial: String {
        String(name.prefix(1)).uppercased()
    }
    
    //used for profile icon background color selection
    func getColorFor(initial: String) -> Color {
        switch initial.lowercased() {
        case "a", "b", "c", "d":
            return Color(hue: 0.1, saturation: 1.0, brightness: 0.8)
        case "e", "f", "g", "h":
            return Color(hue: 0.3, saturation: 1.0, brightness: 0.75)
        case "i", "j", "k", "l":
            return Color(hue: 0.5, saturation: 1.0, brightness: 0.75)
        case "m", "n", "o", "p":
            return Color(hue: 0.7, saturation: 1.0, brightness: 0.75)
        case "q", "r", "s", "t":
            return Color(hue: 0.99, saturation: 1.0, brightness: 0.75)
        case "u", "v", "w":
            return Color(hue: 0.75, saturation: 0.5, brightness: 0.75)
        case "x", "y", "z":
            return Color(hue: 0.0, saturation: 0.0, brightness: 0.3)
        default:
            return Color.black
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button {
                    self.showImagePicker = true
                } label: {
                    VStack {
                        //display letters if they have no contact image, but have a name
                        if contactImage == nil && !name.isEmpty {
                            ZStack {
                                Circle()
                                    .foregroundColor(getColorFor(initial: firstInitial))
                                    .frame(width: 100, height: 100)
                                Text(firstInitial)
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        } else {
                            Image(uiImage: contactImage ?? UIImage(systemName: "person.crop.circle")!)
                                .resizable()
                                .frame(width: 104.75, height: 104.75)
                                .clipShape(Circle())
                        }
                        Text(showEditButton ? "Edit" : "Add")
                            .font(.caption)
                            .padding(4)
                        //                        .offset(x: 30, y: -30)
                        //                        .opacity(contactImage != nil ? 1 : 0)
                    }
                }
                .actionSheet(isPresented: $showImagePicker) {
                    var buttons: [ActionSheet.Button] = [
                        .default(Text("Camera Roll")) {
                            // Handle selecting from camera roll
                            self.showImagePicker.toggle() // Dismiss the action sheet
                            //                        self.selectPhoto(source: .photoLibrary)
                            showPhotoLibrary = true
                        },
                        .cancel()
                    ]
                    
                    if isCameraAvailable() {
                        buttons.insert(.default(Text("Camera"), action: {
                            // Handle taking a new photo
                            self.showImagePicker.toggle() // Dismiss the action sheet
                            
                            //                        self.selectPhoto(source: .camera)
                            //                        ImagePickerView(image: self.$contactImage)
                            showCapturePhoto = true
                        }), at: 1)
                    }
                    
                    return ActionSheet(title: Text("Select Image"), buttons: buttons)
                }
                
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 5)
                
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
                        .frame(height: 157.5)
                        .overlay(
                            Text("\(aboutMe.count)/350")
                                .foregroundColor(aboutMe.count <= 350 ? .black : .red)
                                .padding(4)
                                .padding(.horizontal, 8)
                                .font(Font.caption)
                                .bold()
                                .background(Color.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .offset(x: 0, y: -5)
                                .opacity(aboutMe.isEmpty ? 0.5 : 1)
                                .animation(.easeInOut)
                            , alignment: .bottomTrailing)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                }
                Spacer()
            }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Save character to core data
                        saveCharacter()
                        // Dismiss screen
                        dismiss()
                    }) {
                        Text("Done")
                    }
                    .disabled(!isValidForSave())
                }
            }
            .navigationTitle(character == nil ? "New Contact" : "Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
        
        .onAppear {
            
            //if editing, pre-fill fields
            if let character {
                name = character.name
                isNameRecognizable = character.isRecognizableName
                if let image = character.image {
                    contactImage = image
                    showEditButton = true
                } else {
                    showEditButton = false
                }
                aboutMe = character.promptPrefix
            //if adding new character
            } else {
                //don't show edit image button
                showEditButton = false
//                if contactImage != nil {
//                    showEditButton = true
//                } else {
//                    showEditButton = false
//                }
            }
        }
        //        .navigationBarItems(trailing:
        //            Button(action: {
        //                self.showImagePicker = true
        //            }) {
        //                Image(systemName: "camera")
        //            }
        //        )
        
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePickerView(image: self.$contactImage)
        }
        .sheet(isPresented: $showCapturePhoto) {
            ImagePickerView(image: self.$contactImage, sourceType: .camera)
        }
    }
    
    func isValidForSave() -> Bool {
        guard !name.isEmpty else { return false }
        
        //if overwriting
        if let character {
            //if at least one element has changed
            if character.name != name || character.promptPrefix != aboutMe || character.isRecognizableName != isNameRecognizable {
                //if famous character and has name
                if isNameRecognizable {
                    return true
                } else {
                    //if not famous character but has name and about me
                    if !aboutMe.isEmpty {
                        return true
                    }
                }
            }
            
        //else if is new character save
        } else {
            //if famous character and has name
            if isNameRecognizable {
                return true
            } else {
                //if not famous character but has name and about me
                if !aboutMe.isEmpty {
                    return true
                }
            }
        }
        
        return false
    }
    
    
    func updateImage(_ image: UIImage?) {
        contactImage = image
    }
    
    func saveCharacter() {
        
        // Save character to Core Data
        
        // if overwriting previous character
        if character != nil {
            character!.name = name
            //            character!.imageRef = imageRef
            character!.promptPrefix = aboutMe
            character!.isRecognizableName = isNameRecognizable
            PersistenceController.shared.saveContext()
            
            //refresh HomeScreen to reflect character change
            refreshID = UUID()
            
        //if saving new character
        } else {
            let newChar = Character(context: Constants.context)
            newChar.name = name
            //            newChar.imageRef = imageRef
            newChar.promptPrefix = aboutMe
            newChar.isRecognizableName = isNameRecognizable
            
            //Have their new character send a custom greeting text!
            sendGreetingText(from: newChar)
        }
    }
    
    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func sendGreetingText(from newChar: Character) {
        //define prompt from message text
        let messageText = "Greet me in a way unique to you"
        var prompt: String {
            if isNameRecognizable {
                if !aboutMe.isEmpty {
                    return "Act as \(name). Additionally, you are \(aboutMe). \(messageText)."
                } else {
                    return "Act as \(name). \(messageText)"
                }
            } else {
                if !aboutMe.isEmpty {
                    return "Act as \(aboutMe). If I ask, your name is \(name). \(messageText)."
                } else {
                    //TODO: should not be allowed to do only a name if isRecognizableName is set to false, so if the switch is set to false, the word "optional" in parenthesis should be replaced with "REQUIRED". You will also need an info button next to this switch so they know exactly what it does. The words should be "Well-known person or character" right next to the character, the info button will say, "If it is a well-known person or character such as Selena Gomez or Peter Pan, the about me section is no longer required. Although you may still use it to add aspects to their personality, character, or life story.
                    return "If I ask, your name is \(name). \(messageText)."
                }
            }
        }
        

        
        APIHandler.shared.getResponse(input: prompt) { result in
            switch result {
            case .success(let output):
                
                //format string output to remove empty first line
                let formattedOutput =  output.trimmingCharacters(in: .newlines)
                
                //create message object from string output
                let message = Message(context: Constants.context)
                message.content = formattedOutput
                message.set(newChar)
                
                //save changes to core data
                PersistenceController.shared.saveContext()
                
                self.dismiss()
                
            case .failure(let error):
                print("RESPONSE failed")
            }
        }
        
    }
    
}
    
    struct ImagePickerView: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        var sourceType: UIImagePickerController.SourceType = .photoLibrary
        @Environment(\.presentationMode) private var presentationMode
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = context.coordinator
            picker.allowsEditing = true  // Allow editing before using the taken photo
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: ImagePickerView
            
            init(_ parent: ImagePickerView) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let uiImage = info[.editedImage] as? UIImage {
                    parent.image = uiImage
                }
                parent.presentationMode.wrappedValue.dismiss()
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    
    //struct NewCharacterScreen: View {
    //    @State private var name = ""
    //    @State private var aboutMe = ""
    //    @State private var contactImage: UIImage?
    //    @State private var showImagePicker = false
    //    @State private var showEditButton = true
    //
    //    var body: some View {
    //        VStack {
    //            Button {
    //                self.showImagePicker = true
    //            } label: {
    //                VStack {
    //                    Image(uiImage: contactImage ?? UIImage(systemName: "person.crop.circle")!)
    //                        .resizable()
    //                        .frame(width: 100, height: 100)
    //                        .clipShape(Circle())
    //                        .overlay(
    //                            Button(action: {
    //                                self.showImagePicker = true
    //                            }) {
    //                                Text(showEditButton ? "Edit" : "Add")
    //                                    .font(.caption)
    //                                    .foregroundColor(.white)
    //                                    .padding(4)
    //                                    .background(Color.blue)
    //                                    .clipShape(RoundedRectangle(cornerRadius: 8))
    //                            }
    //                            .offset(x: 30, y: -30)
    //                            .opacity(contactImage != nil ? 1 : 0)
    //                        )
    //                }
    //            }
    //            .actionSheet(isPresented: $showImagePicker) {
    //                ActionSheet(title: Text("Add Photo"), buttons: [
    //                    .default(Text("Camera Roll")) {
    //                        self.showImagePicker.toggle() // Dismiss the action sheet
    //                        self.selectPhoto(source: .photoLibrary)
    //                    },
    //                    .default(Text("Take Photo")) {
    //                        self.showImagePicker.toggle() // Dismiss the action sheet
    //                        self.selectPhoto(source: .camera)
    //                    },
    //                    .cancel()
    //                ])
    //            }
    //
    //            TextField("Name", text: $name)
    //                .textFieldStyle(RoundedBorderTextFieldStyle())
    //                .padding()
    //                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
    //
    //            VStack(alignment: .leading) {
    //                Text("About Me/Personality")
    //                    .font(.headline)
    //                    .padding(.horizontal)
    //
    //                TextEditor(text: $aboutMe)
    //                    .frame(height: 150)
    //                    .overlay(
    //                        Text("\(aboutMe.count)/350")
    //                            .foregroundColor(aboutMe.count <= 350 ? .black : .red)
    //                            .padding(4)
    //                            .padding(.horizontal, 8)
    //                            .background(Color.white.opacity(0.7))
    //                            .clipShape(RoundedRectangle(cornerRadius: 8))
    //                            .offset(x: -10, y: 7.5)
    //                            .opacity(aboutMe.isEmpty ? 0.5 : 1)
    //                            .animation(.easeInOut)
    //                        , alignment: .bottomTrailing)
    //                    .padding(.horizontal)
    //                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
    //            }
    //
    //            Spacer()
    //        }
    //        .padding()
    //        .navigationBarTitleDisplayMode(.inline)
    //        .toolbar {
    //            ToolbarItem(placement: .navigationBarLeading) {
    //                Button(action: {
    //                    // Dismiss Screen
    //                }) {
    //                    Text("Cancel")
    //                }
    //            }
    //            ToolbarItem(placement: .navigationBarTrailing) {
    //                Button(action: {
    //                    // Save character to core data and then dismiss screen
    //                }) {
    //                    Text("Done")
    //                }
    //            }
    //        }
    //        .navigationTitle("New Contact")
    //    }
    //
    //    func selectPhoto(source: UIImagePickerController.SourceType) {
    //        let picker = UIImagePickerController()
    //        picker.sourceType = source
    //        picker.delegate = Coordinator(parent: self)
    //        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true, completion: nil)
    //    }
    //
    //    func updateImage(_ image: UIImage?) {
    //        contactImage = image
    //    }
    //
    //    func saveCharacter() {
    //        // Implement saving character to Core Data
    //    }
    //
    //    func cancel() {
    //        // Implement dismissing screen
    //    }
    //
    //    func done() {
    //        // Implement saving character and dismissing screen
    //    }
    //
    //    // Coordinator to handle UIImagePickerControllerDelegate
    //    func makeCoordinator() -> Coordinator {
    //        return Coordinator(parent: self)
    //    }
    //
    //    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //        let parent: NewCharacterScreen
    //
    //        init(parent: NewCharacterScreen) {
    //            self.parent = parent
    //        }
    //
    //        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
    //                parent.updateImage(uiImage)
    //            }
    //            picker.dismiss(animated: true, completion: nil)
    //        }
    //
    //        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //            picker.dismiss(animated: true, completion: nil)
    //        }
    //    }
    //}
    
    
    struct NewCharacterScreen_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                let refreshID = Binding<UUID>(get: {
                            // Return your initial value here
                            return UUID()
                        }, set: { newValue in
                            // Handle the updated value here
                        })
                NewCharacterScreen(refreshID: refreshID)
            }
        }
    }
    
