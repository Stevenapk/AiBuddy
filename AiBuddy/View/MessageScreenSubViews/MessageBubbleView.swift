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
    var proxy: ScrollViewProxy
    var character: Character
    var bottomMessageIndex: Int { messages.indices.last ?? 0 }
    
    @State private var hasPerformedInitialSetup = false
    
    @Binding var selectedMessage: Message?
    @Binding var isTextFieldFocused: Bool
    @Binding var messages: [Message]
    @Binding var messageDeleted: Bool
    
    func scrollToBottom(with proxy: ScrollViewProxy) {
        guard messages.indices.contains(bottomMessageIndex) else {
            return // Message index is out of bounds, do not scroll
        }
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
                            if !hasPerformedInitialSetup {
                                
                                //Set has performed initial setup to true
                                hasPerformedInitialSetup = true
                                
                                //scroll to selected message from prior search
                                if let scrollToIndex = messageIndexToScrollTo {
                                    proxy.scrollTo(scrollToIndex, anchor: .bottom)
                                } else {
                                    //scroll to bottom (most recent message) if no selectedIndex                      }
                                    scrollToBottom(with: proxy)
                                }
                            }
                        }
                }
            )
            .contextMenu {
                Button(action: {
                    copyTextToClipboard(text: message.content)
                }) {
                    Text("Copy")
                    Image(systemName: "doc.on.doc")
                }
                Button(action: {
                    // Delete character action
                    selectedMessage = message
                }) {
                    Text("Delete")
                    Image(systemName: "trash.fill")
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
    
    func copyTextToClipboard(text: String) {
        UIPasteboard.general.string = text
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
        } else {
            messageDeleted = true
        }
        
        // Save changes to core data
        PersistenceController.shared.saveContext()
    }
}
