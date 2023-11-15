//
//  MessageList.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/17/23.
//

import SwiftUI

struct MessageList: View {
    
    @ObservedObject var viewModel: MessageScreenViewModel
    
    @State private var scrollOffset: CGFloat = 0
    @State private var messageDeleted: Bool = false
    
    @Binding var keyboardDismissed: Bool
    
    var messageIndexToScrollTo: Int?
    var bottomMessageIndex: Int { viewModel.messages.indices.last ?? 0 }
    var character: Character
    
    // Function to scroll to bottom with animation
    func scrollToBottom(with proxy: ScrollViewProxy) {
        guard viewModel.messages.indices.contains(bottomMessageIndex) else {
            return // Message index is out of bounds, do not scroll
        }
        withAnimation {
            proxy.scrollTo(bottomMessageIndex, anchor: .bottom)
        }
    }
    
    func getKeyboardHeight() -> CGFloat {
        return UIScreen.main.bounds.height > 800 ? 300 : 200
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.messages.indices, id: \.self) { index in
                        // Calculate top padding based on message sender
                        let previousIndex = index > 1 ? (index-1) : 0
                        let topPadding = viewModel.messages[index].isSentByUser == viewModel.messages[previousIndex].isSentByUser ? 0.0 : 15.0
                        
                        // Display timestamp if the message is the first or has a time gap
                        if index == 0 || viewModel.messages[index].timestamp.timeIntervalSince(viewModel.messages[index-1].timestamp) >= 3600 {
                            
                            TimestampView(date: viewModel.messages[index].timestamp)
                        }
                        
                        // Display individual message bubble
                        MessageBubbleView(
                            message: viewModel.messages[index],
                            index: index,
                            messageIndexToScrollTo: messageIndexToScrollTo,
                            proxy: proxy,
                            character: character,
                            selectedMessage: $viewModel.selectedMessage,
                            isTextFieldFocused: $viewModel.isTextFieldFocused,
                            messages: $viewModel.messages,
                            messageDeleted: $messageDeleted
                        )
                        .padding(.top, topPadding)
                    }
                    
                    // Spacer for additional bottom padding
                    Spacer().frame(height: 50)
                }
                .padding(.horizontal)
                .offset(y: scrollOffset)
                .allowsHitTesting(keyboardDismissed) // Allow gestures to pass through
                .onChange(of: viewModel.isTextFieldFocused) { focused in
                    if focused {
                        // Bring up the keyboard and scroll to the bottom
                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                        scrollToBottom(with: proxy)
                    }
                }
                .onChange(of: viewModel.messages) { _ in
                    //if the change to messages was anything but one being removed (a message was added, etc.)
                    if !messageDeleted {
                        //scroll to the bottom of the message list
                        scrollToBottom(with: proxy)
                    } else {
                        //reset the deletion flag
                        messageDeleted = false
                    }
                }
            }
            
            // Gesture for dismissing the keyboard with a drag gesture
            .gesture(DragGesture()
                .onChanged { gesture in
                        // Detect scroll position
                        let offset = gesture.translation.height
                        let predictedEndLocation = gesture.predictedEndLocation.y
                        scrollOffset = offset
                        // Dismiss keyboard when scrolling downward past keyboard height
                    if offset > 0 && predictedEndLocation > (getKeyboardHeight() - viewModel.textFieldHeight) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        keyboardDismissed = true
                    }
                }
                .onEnded { gesture in
                    // Additional code to run when dragging ends, if needed
                    // Detect scroll position
                    let offset = gesture.translation.height
                    scrollOffset = offset
                    // Dismiss keyboard when scrolling downward past keyboard height
                    if offset > 0 && offset > getKeyboardHeight() {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        keyboardDismissed = true
                    }
                }
            )
        }
    }
}
