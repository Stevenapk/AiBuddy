//
//  MessageList.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/17/23.
//

import SwiftUI

struct MessageList: View {
    
    @Binding var isTextFieldFocused: Bool
    @Binding var messages: [Message]
    @Binding var selectedMessage: Message?
    @Binding var textFieldHeight: CGFloat
    @State private var scrollOffset: CGFloat = 0
    var messageIndexToScrollTo: Int?
    var bottomMessageIndex: Int { messages.indices.last ?? 0 }
    var character: Character // does this need to be binding var?
    
    func scrollToBottom(with proxy: ScrollViewProxy) {
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
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages.indices, id: \.self) { index in
                        if index == 0 || messages[index].timestamp.timeIntervalSince(messages[index-1].timestamp) >= 3600 {
                            
                            TimestampView(date: messages[index].timestamp)
                        }
                        MessageBubbleView(
                            message: messages[index],
                            index: index,
                            messageIndexToScrollTo: messageIndexToScrollTo,
                            selectedMessage: $selectedMessage,
                            isTextFieldFocused: $isTextFieldFocused,
                            messages: $messages,
                            proxy: proxy,
                            character: character
                        )
                    }
                }
                .padding(.horizontal)
                .offset(y: scrollOffset)
                .allowsHitTesting(false) // Allow gestures to pass through
                .onChange(of: isTextFieldFocused) { focused in
                    print("changedddddddd")
                    if focused {
                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            
            .gesture(DragGesture()
                .onChanged { gesture in
                        // Detect scroll position
                print("gesture is CHANGGINGGGG")
                    print("Y POINT: \(gesture.location.y)")
                    print("end point prediction: \(gesture.predictedEndLocation.y)")
                        let offset = gesture.translation.height
                        let predictedEndLocation = gesture.predictedEndLocation.y
//                    let textfieldViewHeight = 100.0
                        scrollOffset = offset
                        print(scrollOffset)
                        // Dismiss keyboard when scrolling downward past keyboard height
                    if offset > 0 && predictedEndLocation > (getKeyboardHeight() - textFieldHeight) {
                        print("CHAHAHAHANGED")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .onEnded { gesture in
                    // Additional code to run when dragging ends, if needed
                    // Detect scroll position
                    print("gesture is ENDINGGGGG")
                    let offset = gesture.translation.height
                    scrollOffset = offset
                    print(scrollOffset)
                    // Dismiss keyboard when scrolling downward past keyboard height
                    if offset > 0 && offset > getKeyboardHeight() {
                        print("ENDINNGGGG")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }

            )
        }
        
    }
}
