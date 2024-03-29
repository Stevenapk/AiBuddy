//
//  MessageBubble.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/17/23.
//

import SwiftUI

struct MessageBubble: View {
    
    var text: String
    var timestamp: Date
    var isSentByUser: Bool
    
    @State var showTimestamp: Bool = false
    
    var body: some View {
        HStack() {
            if isSentByUser {
                Spacer() // Add a spacer to push the message bubble to the right edge if message was sent by user
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
                        .foregroundColor(isSentByUser ? .white : .primary)
                        .font(.system(size: 16))
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
                    Spacer() // Add a spacer to push the message bubble to the left edge if message is an ai response
                }
                if showTimestamp {
                    HStack {
                        if isSentByUser {
                            // Aligned to right edge
                            Spacer()
                            Text(timestamp.localizedTimeString)
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .padding(.trailing, 30)
                                .padding(.bottom, 1)
                        }
                        if !isSentByUser {
                            // Aligned to left edge
                            Text(timestamp.localizedTimeString)
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .padding(.leading, 30)
                                .padding(.bottom, 0)
                            Spacer()
                        }
                    }
                }
            }
            //show the timestamp below message bubble when message bubble is tapped
            .onTapGesture {
                showTimestamp.toggle()
            }
        }
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        
        // Provide random Binding<UUID> for preview
        let refreshID = Binding<UUID>(get: {
            return UUID()
        }, set: { newValue in
        })
        
        MessageScreen(viewModel: MessageScreenViewModel(messages: []), refreshManager: RefreshManager(), refreshID: refreshID, character: Character(context: PersistenceController.shared.container.viewContext), unreadMessageCount: 0)
    }
}
