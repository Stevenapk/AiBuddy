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
    
    var messageIndexToScrollTo: Int?
    var bottomMessageIndex: Int { viewModel.messages.indices.last ?? 0 }
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
                    ForEach(viewModel.messages.indices, id: \.self) { index in
                        if index == 0 || viewModel.messages[index].timestamp.timeIntervalSince(viewModel.messages[index-1].timestamp) >= 3600 {
                            
                            TimestampView(date: viewModel.messages[index].timestamp)
                        }
                        MessageBubbleView(
                            message: viewModel.messages[index],
                            index: index,
                            messageIndexToScrollTo: messageIndexToScrollTo,
                            selectedMessage: $viewModel.selectedMessage,
                            isTextFieldFocused: $viewModel.isTextFieldFocused,
                            messages: $viewModel.messages,
                            proxy: proxy,
                            character: character
                        )
                    }
                }
                .padding(.horizontal)
                .offset(y: scrollOffset)
                .allowsHitTesting(false) // Allow gestures to pass through
                .onChange(of: viewModel.isTextFieldFocused) { focused in
                    print("changedddddddd")
                    if focused {
                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            
            .gesture(DragGesture()
                .onChanged { gesture in
                        // Detect scroll position
                    print("end point prediction: \(gesture.predictedEndLocation.y)")
                        let offset = gesture.translation.height
                        let predictedEndLocation = gesture.predictedEndLocation.y
//                    let textfieldViewHeight = 100.0
                        scrollOffset = offset
                        print(scrollOffset)
                        // Dismiss keyboard when scrolling downward past keyboard height
                    if offset > 0 && predictedEndLocation > (getKeyboardHeight() - viewModel.textFieldHeight) {
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
