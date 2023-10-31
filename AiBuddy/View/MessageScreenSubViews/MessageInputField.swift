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
            Rectangle() // Add a rectangle as the first view
                .foregroundColor(Color(uiColor: .systemBackground)) // Set the desired background color
                .frame(height: textFieldHeight-10)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.secondaryLabel), lineWidth: 1)
                    .frame(height: textFieldHeight-30)
                    .padding(.bottom, 17.5)
                    .padding(.horizontal, 25)
                HStack(alignment: .bottom) {
                    TextField("Type a message...", text: $viewModel.messageText, axis: .vertical)
                        .font(Font.subheadline)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .padding(.horizontal, 10)
                    //                            .background(Color(.clear))
                        .onTapGesture {
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
                    if                         // make label transparent when blank
                        !viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
