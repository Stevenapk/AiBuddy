//
//  MessageScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Combine

struct MessageScreen: View {
    
    var character: Character
    
    //instead of this have a Message type with a string and a isSentByUser bool property
    @State var messages: [String] = []
    
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
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text("Contact Name")
                    .font(.headline)
                Spacer()
                EmptyView() // Add a placeholder for any additional buttons/icons
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Message List
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Replace with dynamic messages from the selected contact
                    ForEach(messages.indices, id: \.self) { index in
                                    MessageBubble(text: messages[index], isSentByUser: index % 2 == 0)
                                }
                }
                .padding()
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
                    self.messages.append(messageText)
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
        // Handle sending message
        print("RESPONSE WHYYYY")
        APIHandler.shared.getResponse(input: messageText) { result in
            switch result {
            case .success(let output):
                print("RESPONSE \(output)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    print("RESPONSE DELAYED \(models)")
                }
                let formattedOutput =  output.trimmingCharacters(in: .newlines)
                self.messages.append(formattedOutput)
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
        MessageScreen(character: Character(name: "Phil"))
    }
}
