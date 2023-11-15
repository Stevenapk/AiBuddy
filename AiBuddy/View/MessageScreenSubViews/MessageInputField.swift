//
//  MessageInputField.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/18/23.
//

import SwiftUI

struct MessageInputField: View {
    
    var character: Character
    @ObservedObject var viewModel: MessageScreenViewModel
    @State private var textFieldHeight: CGFloat = 70
    @Binding var keyboardDismissed: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(Color(uiColor: .systemBackground))
                .frame(height: textFieldHeight-10)
            ZStack {
                // Rounded Rectangle Background to contain textfield and send button
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.secondaryLabel), lineWidth: 1)
                    .frame(height: textFieldHeight-30)
                    .padding(.bottom, 17.5)
                    .padding(.horizontal, 25)
                // HStack containing the text field and send button
                HStack(alignment: .bottom) {
                    // User message input field with placeholder and dynamic height
                    TextField("Type a message...", text: $viewModel.messageText, axis: .vertical)
                        .font(Font.subheadline)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            // Dismiss keyboard when tapping on the text field if it was dismissed
                            if keyboardDismissed == true {
                                keyboardDismissed = false
                            }
                        }
                        .background(GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.size.height) { newHeight in
                                    // Respond to changes in height
                                    textFieldHeight = newHeight + 40
                                }
                        })
                    // Hide send message button when user inputted text is empty
                    if !viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        SendMessageButton(viewModel: viewModel, character: character)
                    }
                }
                .padding(.bottom, 17.5)
                .padding(.horizontal, 25)
            }
        }
        .gesture(
            DragGesture().onChanged { value in
                // If User is scrolling down on text field view...
                if value.translation.height > 0 {
                    //dismiss keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    keyboardDismissed = true
                }
            }
        )
    }
}
