//
//  MessageScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Combine
import CoreData
import Speech
import AVFoundation

struct MessageScreen: View {
    
    @State var selectedMessage: Message? = nil
    @Binding var refreshID: UUID
    @State private var isRecording = false
    
    func dismissScreen() {
        dismiss()
    }
    
    @Environment(\.dismiss) var dismiss
    
    var character: Character
    
    // Fetch Messages from Core Data and sort by timestamp
    //    @FetchRequest(
    //        entity: Message.entity(),
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)]
    //    ) var messages: FetchedResults<Message>
    
    @State var messages: [Message]
    
    var messageIndexToScrollTo: Int?
    
    @State private var models: [String] = []
    
    @State private var messageText = ""
    @State private var responseText = ""
    @State private var isTextFieldFocused = false
    
    @State private var textFieldHeight: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            NavigationBar(dismiss: dismissScreen, character: character, refreshID: $refreshID, isTextFieldFocused: $isTextFieldFocused)
            
            
            // Message List
            MessageList(isTextFieldFocused: $isTextFieldFocused, messages: $messages, selectedMessage: $selectedMessage, textFieldHeight: $textFieldHeight, messageIndexToScrollTo: messageIndexToScrollTo, character: character)
 

            ZStack(alignment: .bottom) {
                Rectangle() // Add a rectangle as the first view
                    .foregroundColor(Color(uiColor: .systemBackground)) // Set the desired background color
                               .frame(height: textFieldHeight-10)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.secondaryLabel), lineWidth: 1)
                    .frame(height: textFieldHeight-30)
                    .padding(.bottom, 17.5)
                    .padding(.horizontal, 25)
                    HStack(alignment: .bottom) {
                        TextField("Type a message...", text: $messageText, axis: .vertical)
                            .font(.caption)
                            .padding(.bottom, 10)
                            .padding(.horizontal, 10)
//                            .background(Color(.clear))
                            .onTapGesture {
                                // Assuming you want to set isTextFieldFocused here
                                
                            }
                            .background(GeometryReader { geo in
                                                Color.clear
                                                    .onChange(of: geo.size.height) { newHeight in
                                                        // Respond to changes in height
                                                            textFieldHeight = newHeight + 30
                                                        
                                                    }
                                            })
                        if                         // make label transparent when blank
                            !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button {
                                sendMessage()
                                //                    Task {
                                //                        await sendMessage()
                                //                    }
                            } label: {
                                ZStack {
                                    Circle()
                                        .frame(width: 30)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 5)
                                        .padding(.trailing, 5)
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 30))
                                        .padding(.bottom, 5)
                                        .padding(.trailing, 5)
                                }
                            }
                            //                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // disabled when blaul
                        }
                        
                        //
                        //            Button(action: sendAction) {
                        //                Image(systemName: "paperplane")
                        //                    .font(.headline)
                        //            }
                    }
                    .padding(.bottom, 17.5)
                    .padding(.horizontal, 25)
                    .gesture(
                        DragGesture().onChanged { value in
                            // If User is scrolling down on text field...
                            if value.translation.height > 0 {
                                //then, dismiss keyboard
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                
                            }
                        }
                    )
                
            }
//            }

            
            //            TextInputFieldView(text: $messageText, sendAction: sendMessage)
        }
//        .padding(.bottom, isTextFieldFocused ? getKeyboardHeight() : 0)
//        .animation(.easeInOut(duration: 0.3))
        .onReceive(Publishers.keyboardHeight) { height in
            self.isTextFieldFocused = height > 0
        }
//        .keyboardAdaptive() // Automatically adjust view position for keyboard
    }
    
    func sendMessage() {
        
        //create message object from user's sent text
        let message = Message(context: Constants.context)
        message.content = messageText
        message.isSentByUser = true
        message.set(character)
        
        //add to array to update view
        messages.append(message)
        
        //save sent message
        PersistenceController.shared.saveContext()
        
        let prompt = character.promptWithContextFrom(messageText)
        
        //clear textfield
        messageText = ""
        
                APIHandler.shared.getResponse(input: prompt) { result in
                    switch result {
                    case .success(let output):
                        
                        //removes blank lines and "." lines and returns output
                        func removeUnwantedLines(from input: String) -> String {
                            
                            // Split the input string into an array of lines
                            let lines = input.split(separator: "\n")
                            // Create an empty string to store the result
                            var result = ""
                            // Create a flag to track whether text has been found
                            var foundText = false

                            for line in lines {
                                // Trim leading and trailing whitespaces from the line
                                let trimmedLine = line.trimmingCharacters(in: .whitespaces)

                                // Check if the trimmed line is not empty and not just a period
                                if !trimmedLine.isEmpty && trimmedLine != "." {
                                    // If text is found, set the flag to true and append the line to the result
                                    foundText = true
                                    result += "\(line)\n"
                                } else if foundText {
                                    // If text has been found previously, append the line to the result
                                    result += "\(line)\n"
                                }
                            }

                            // Remove the last line if it is blank
                            if result.last == "\n" {
                                result.removeLast()
                            }

                            // Return the properly formatted result
                            return result
                        }

                        let formattedOutput = removeUnwantedLines(from: output)
        
                        //create message object from string output
                        let message = Message(context: Constants.context)
                        if !formattedOutput.isEmpty {
                            message.content = formattedOutput
                        } else {
                            message.content = "..."
                        }
                        message.set(character)
        
                        //save changes to core data
                        PersistenceController.shared.saveContext()
        
                        //append to array
                        self.messages.append(message)
        
                        self.models.append(output)
                        responseText = models.joined(separator: " ")
                    case .failure(let error):
                        print("RESPONSE failed")
                    }
                }

    }

    
    func getKeyboardHeight() -> CGFloat {
        return UIScreen.main.bounds.height > 800 ? 300 : 200
    }
    
}

extension Calendar {
    func isDateInLastWeek(_ date: Date) -> Bool {
        guard let oneWeekAgo = self.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return date > oneWeekAgo
    }
}

extension Date {
    
    var localizedMediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, M d"
        return formatter.string(from: self)
    }
    
    var localizedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    var dayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    var localizedTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var formattedString: String {
        if Calendar.current.isDateInToday(self) {
            return localizedTimeString
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else if Calendar.current.isDateInLastWeek(self) {
            return dayOfWeekString
        } else {
            return localizedDateString
        }
    }
    
    var longFormattedString: String {
        if Calendar.current.isDateInToday(self) {
            return localizedTimeString
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday \(localizedTimeString)"
        } else if Calendar.current.isDateInLastWeek(self) {
            return "\(dayOfWeekString) \(localizedTimeString)"
        } else {
            return "\(localizedMediumDateString) at \(localizedTimeString)"
        }
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
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
        
        MessageScreen(refreshID: refreshID, character: Character(context: PersistenceController.shared.container.viewContext), messages: [])
    }
}

//struct TextInputFieldView: View {
//    @Binding var text: String
//    var sendAction: () async -> Void
//
//    var body: some View {
//        HStack {
//            TextField("Type a message...", text: $text)
//                .padding(10)
//                .background(Color(.systemGray5))
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .onTapGesture {
//                    // Assuming you want to set isTextFieldFocused here
//                }
//
//            Button {
//                Task {
//                    await sendAction()
//                }
//            } label: {
//                Image(systemName: "paperplane")
//                    .font(.headline)
//            }
//
////
////            Button(action: sendAction) {
////                Image(systemName: "paperplane")
////                    .font(.headline)
////            }
//        }
//        .padding()
//    }
//}




//struct MessageSwift: Identifiable {
//    var id = UUID()
//    var idString: String {
//        id.uuidString
//    }
//    var content = ""
//    var timestamp: Date = Date()
//    var isSentByUser = false
//    var character: Character
//}
