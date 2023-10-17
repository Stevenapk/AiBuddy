//
//  MessageBubbleView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/17/23.
//

import SwiftUI

struct MessageBubbleView: View {
    var message: Message
    var index: Int
    var messageIndexToScrollTo: Int?
    @Binding var selectedMessage: Message?
    @Binding var isTextFieldFocused: Bool
    @Binding var messages: [Message]
    var proxy: ScrollViewProxy // Include proxy property
    var character: Character
    
    var bottomMessageIndex: Int { messages.indices.last ?? 0 }
    
    func scrollToBottom(with proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(bottomMessageIndex, anchor: .bottom)
        }
    }
    
    var body: some View {
        MessageBubble(text: message.content, timestamp: message.timestamp, isSentByUser: message.isSentByUser)
            .id(index)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            //scroll to selected message from prior search
                            if let scrollToIndex = messageIndexToScrollTo, index == scrollToIndex {
                                let minY = geometry.frame(in: .global).minY
                                let height = geometry.size.height
                                proxy.scrollTo(index, anchor: .top)
                            } else {
                                //scroll to bottom (most recent message) if no selectedIndex
                                scrollToBottom(with: proxy)
                            }
                        }
                }
            )
            .contextMenu {
                Button(action: {
                    // Delete character action
                    selectedMessage = message
                }) {
                    Text("Delete")
                    Image(systemName: "trash.fill")
                }
            }
            .onChange(of: isTextFieldFocused) { isFocused in
                if isFocused {
                    scrollToBottom(with: proxy)
                }
            }
            .actionSheet(item: $selectedMessage) { message in
                ActionSheet(
                    title: Text(""),
                    message: Text("This message will be deleted."),
                    buttons: [
                        .destructive(Text("Delete"), action: {
                            handleDeleteMessage(message)
                        }),
                        .cancel(Text("Cancel"))
                    ]
                )
            }
    }
    
    func handleDeleteMessage(_ message: Message) {
        // Copy messageContent
        let text = message.content
        
        // Delete message
        Constants.context.delete(message)
        
        // Remove the message from the messages array to properly update this view
        if let index = messages.firstIndex(of: message) {
            messages.remove(at: index)
        }
        
        // If the last text in the chain was the one deleted, update the lastText and last modified date of the corresponding character/contact
        if text == character.lastText {
            if let lastMessage = messages.last {
                character.lastText = lastMessage.content
                character.modified = lastMessage.timestamp
            } else {
                character.lastText = ""
            }
        }
        
        // Save changes to core data
        PersistenceController.shared.saveContext()
    }
}
