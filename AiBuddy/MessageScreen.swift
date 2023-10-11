//
//  MessageScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Combine
import CoreData


final class DataManager {
    static let shared = DataManager()
    
    var allMessages = [MessageSwift]()
    var allCharacters = [CharacterSwift]()
}

struct MessageSwift: Identifiable {
    var id = UUID()
    var idString: String {
        id.uuidString
    }
    var content = ""
    var timestamp: Date = Date()
    var isSentByUser = false
    var character: Character
}


struct MessageScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    var character: Character
    
    //instead of this have a Message type with a string and a isSentByUser bool property
//    @State var messages: [String] = []
    
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
    
    var body: some View {
        VStack {
            // Navigation Bar
            HStack {
                Button(action: {
                    // Handle back button action
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(character.name)
                    .font(.headline)
                Spacer()
                EmptyView() // Add a placeholder for any additional buttons/icons
            }
            .padding()
            .background(Color(.systemGray6))
            
            
            // Message List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // Replace with dynamic messages from the selected contact
                        //                    ForEach(messages.indices, id: \.self) { index in
                        //                                    MessageBubble(text: messages[index], isSentByUser: index % 2 == 0)
                        //                                }
                        //                }
                        ForEach(messages.indices, id: \.self) { index in
                            MessageBubble(text: messages[index].content, isSentByUser: messages[index].isSentByUser)
                                .id(index) // Ensure each message has a unique ID
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .onAppear {
                                                if let scrollToIndex = messageIndexToScrollTo, index == scrollToIndex {
                                                    let minY = geometry.frame(in: .global).minY
                                                    let height = geometry.size.height
                                                    
                                                    let offset = minY + height
                                                    proxy.scrollTo(index, anchor: .top)
                                                }
                                            }
                                    }
                                )
                        }
                        //                    ForEach(messages) { message in
                        //                        MessageBubble(text: message.content, isSentByUser: message.isSentByUser)
                        //                    }
                    }
                    .padding()
                }
            }
            
            // Text Input Field
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
                
                Button(action: {
                    // Handle send button action
                    // Create user message object from sent string
                    let message = Message(context: Constants.context)
                    message.content = messageText
                    message.isSentByUser = true
                    message.set(character)
                    
                    // Save changes to core data
                    PersistenceController.shared.saveContext()
                    
                    // Append to array for UI update
                    self.messages.append(message)
                    
                    // Send message to AI Personality and await response
                    sendMessage()
                }) {
                    Image(systemName: "paperplane")
                        .font(.headline)
                }
            }
            .padding()
        }
        .padding(.bottom, isTextFieldFocused ? getKeyboardHeight() : 0)
        .animation(.easeInOut(duration: 0.3))
        .onReceive(Publishers.keyboardHeight) { height in
            self.isTextFieldFocused = height > 0
        }
    }
    
    func sendMessage() {
        
        //define prompt from message text
        let prompt = character.promptFrom(messageText)
        
        //clear textfield
        messageText = ""
        
        APIHandler.shared.getResponse(input: prompt) { result in
            switch result {
            case .success(let output):
                
                //format string output to remove empty first line
                let formattedOutput =  output.trimmingCharacters(in: .newlines)
                
                //create message object from string output
                let message = Message(context: Constants.context)
                message.content = formattedOutput
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

struct MessageBubble: View {
    var text: String
    var isSentByUser: Bool
    
    var body: some View {
        HStack() {
            if isSentByUser {
                Spacer() // Add a spacer to push the message bubble to the right edge
            }
            
            VStack(alignment: isSentByUser ? .trailing : .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        if !isSentByUser {
                            Triangle(direction: .southwest)
                                .fill(Color(.systemGray3))
                                .frame(width: 25, height: 10)
                                .offset(CGSize(width: 16, height: 15))
                            
                        }
                        Text(text)
                            .foregroundColor(isSentByUser ? .white : .black)
                            .padding(10)
                            .background(isSentByUser ? Color.blue : Color(.systemGray3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        if isSentByUser {
                            Triangle(direction: .southeast)
                                .fill(Color.blue)
                                .frame(width: 25, height: 10)
                                .offset(CGSize(width: -16, height: 15))
                        }
                    
                
            }
            if !isSentByUser {
                Spacer() // Step 8: Add a spacer to push the message bubble to the left edge
            }
        }
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

struct Triangle: Shape {
    var direction: TriangleDirection
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let startPoint = CGPoint(x: rect.width * direction.startPoint.x, y: rect.height * direction.startPoint.y)
            let midPoint = CGPoint(x: rect.width * direction.middlePoint.x, y: rect.height * direction.middlePoint.y)
            let endPoint = CGPoint(x: rect.width * direction.endPoint.x, y: rect.height * direction.endPoint.y)
            
            path.move(to: startPoint)
            path.addLine(to: midPoint)
            path.addLine(to: endPoint)
            path.closeSubpath()
            
            return path
        }
}

enum TriangleDirection {
    case north, northeast, east, southeast, south, southwest, west, northwest
    
    var startPoint: CGPoint {
        switch self {
        case .north: return CGPoint(x: 0.5, y: 0)
        case .northeast: return CGPoint(x: 1, y: 0)
        case .east: return CGPoint(x: 1, y: 0.5)
        case .southeast: return CGPoint(x: 1, y: 1)
        case .south: return CGPoint(x: 0.5, y: 1)
        case .southwest: return CGPoint(x: 0, y: 1)
        case .west: return CGPoint(x: 0, y: 0.5)
        case .northwest: return CGPoint(x: 0, y: 0)
        }
    }
    
    var middlePoint: CGPoint {
        return CGPoint(x: 0.5, y: -0.5)
    }
    
    var endPoint: CGPoint {
        return CGPoint(x: 0.5, y: 0.5)
    }
}
//In this modified code, the TriangleDirection enum now includes middlePoint, which is the point at the bottom-center of the triangle. The Triangle struct now uses this point to draw the isosceles triangle.
//
//You can use this updated Triangle struct with the direction parameter, and it will create an isosceles triangle as desired.
//






extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

struct MessageScreen_Previews: PreviewProvider {
    static var previews: some View {
        MessageScreen(character: Character(context: PersistenceController.shared.container.viewContext), messages: [])
    }
}
