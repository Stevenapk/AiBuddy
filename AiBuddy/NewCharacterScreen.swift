//
//  NewCharacterScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/9/23.
//

import SwiftUI
import UIKit

struct NewCharacterScreen: View {
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
                .padding()
            
            VStack(alignment: .leading) {
                Text("About Me/Personality")
                    .font(.headline)
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
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Dismiss Screen
                }) {
                    Text("Cancel")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Save character to core data and then dismiss screen
                }) {
                    Text("Done")
                }
                .disabled(name.isEmpty)
            }
        }
        .navigationTitle("New Contact")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if contactImage != nil {
                showEditButton = true
            } else {
                showEditButton = false
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
    
    
    func updateImage(_ image: UIImage?) {
        contactImage = image
    }
    
    func saveCharacter() {
        // Implement saving character to Core Data
    }
    
    func cancel() {
        // Implement dismissing screen
    }
    
    func done() {
        // Implement saving character and dismissing screen
    }
    
    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
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
            NewCharacterScreen()
        }
    }
}

