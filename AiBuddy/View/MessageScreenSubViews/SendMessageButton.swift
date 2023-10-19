//
//  SendMessageButton.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/18/23.
//

import SwiftUI

struct SendMessageButton: View {
    
    @ObservedObject var viewModel: MessageScreenViewModel
    var character: Character
    
    var body: some View {
        Button {
            viewModel.sendMessage(to: character)
        } label: {
            ZStack {
                Circle()
                    .frame(width: 25)
                    .foregroundColor(.white)
                    .padding(.bottom, 6)
                    .padding(.trailing, 5)
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 25))
                    .padding(.bottom, 6)
                    .padding(.trailing, 5)
            }
        }
    }
}
