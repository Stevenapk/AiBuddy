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

struct SendMessageButton: View {
    
    @ObservedObject var viewModel: MessageScreenViewModel
    var character: Character
    
    var body: some View {
        Button {
            viewModel.sendMessage(to: character)
        } label: {
            ZStack {
                Circle()
                    .frame(width: 25)
                    .foregroundColor(.white)
                    .padding(.bottom, 6)
                    .padding(.trailing, 5)
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 25))
                    .padding(.bottom, 6)
                    .padding(.trailing, 5)
            }
        }
    }
}

struct MessageInputField: View {
    
    var character: Character
    @ObservedObject var viewModel: MessageScreenViewModel
    @State private var textFieldHeight: CGFloat = 70
    
    var body: some View {
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
                    TextField("Type a message...", text: $viewModel.messageText, axis: .vertical)
                        .font(Font.subheadline)
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
                                                        textFieldHeight = newHeight + 40
                                                }
                                        })
                    if                         // make label transparent when blank
                        !viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        SendMessageButton(viewModel: viewModel, character: character)
                    }
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
    }
}

class MessageScreenViewModel: ObservableObject {
    
    init(messages: [Message]) {
        self.messages = messages
    }
    
    // Properties
    @Published var selectedMessage: Message? = nil
    @Published var messages: [Message]
    @Published var messageText = ""
    @Published var responseText = ""
    @Published var isTextFieldFocused = false
    @Published var textFieldHeight: CGFloat = 70

    // Functions
    func unmarkUnreadMessage(for character: Character) {
        //if character has an unread message,
        if character.hasUnreadMessage {
            //set character has unread message to false, since they have now viewed it by opening this screen
            character.hasUnreadMessage = false
            //save changes to context
            PersistenceController.shared.saveContext()
        }
    }
    
    func sendMessage(to character: Character) {
        
        //create message object from messageText field
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
        
        //send message
        APIHandler.shared.sendMessage(prompt, to: character) { response in
            if let response {
                //append response to messages array
                self.messages.append(response)
            }
        }

    }

    func getKeyboardHeight() -> CGFloat {
        return UIScreen.main.bounds.height > 800 ? 300 : 200
    }
    
}

struct MessageScreen: View {
    
    @State private var hasPerformedInitialSetup = false
    
    @ObservedObject var viewModel: MessageScreenViewModel
    
//    @State var selectedMessage: Message? = nil
    @Binding var refreshID: UUID
//    @State private var isRecording = false
//
    @Environment(\.dismiss) var dismiss
    
    var character: Character
    
    // Fetch Messages from Core Data and sort by timestamp
    //    @FetchRequest(
    //        entity: Message.entity(),
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)]
    //    ) var messages: FetchedResults<Message>
//
//    @State var messages: [Message]
    
    var messageIndexToScrollTo: Int?
    
//    @State private var models: [String] = []
//
//    @State private var messageText = ""
//    @State private var responseText = ""
//    @State private var isTextFieldFocused = false
//
//    @State private var textFieldHeight: CGFloat = 70

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            NavigationBar(character: character, refreshID: $refreshID, isTextFieldFocused: $viewModel.isTextFieldFocused)
            
            // Message List
            MessageList(viewModel: viewModel, messageIndexToScrollTo: messageIndexToScrollTo, character: character)
 
            // Message Input Field
            MessageInputField(character: character, viewModel: viewModel)

        }
        .onAppear {
            //On only first screen setup
            if !hasPerformedInitialSetup {
                
                //set hasPerformedInitialSetup to true
                hasPerformedInitialSetup = true
                
                //unmark the unread message and save this change
                viewModel.unmarkUnreadMessage(for: character)
            }
        }
//        .padding(.bottom, isTextFieldFocused ? getKeyboardHeight() : 0)
//        .animation(.easeInOut(duration: 0.3))
        .onReceive(Publishers.keyboardHeight) { height in
            viewModel.isTextFieldFocused = height > 0
        }
//        .keyboardAdaptive() // Automatically adjust view position for keyboard
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
        
        MessageScreen(viewModel: MessageScreenViewModel(messages: []), refreshID: refreshID, character: Character(context: PersistenceController.shared.container.viewContext))
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
