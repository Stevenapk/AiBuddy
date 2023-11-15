//
//  ToggleFamousCharacterView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct ToggleFamousCharacterView: View {
    @State private var showToggleInfoView = false
    @Binding var isNameRecognizable: Bool
    @Binding var name: String

    var body: some View {
        HStack {
            //Toggle for "Famous Character"
            Toggle("Famous Character", isOn: $isNameRecognizable)
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .padding(.trailing, 5)
            //Info button
            Button(action: {
                showToggleInfoView = true
            }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .offset(y: 1)
            }
            //Info alert to describe what justifies toggling your new contact as a "famous character"
            .alert(isPresented: $showToggleInfoView) {
                Alert(title: Text("Famous Character"), message: Text("If \(!name.isEmpty ? "\""+name+"\"" : "the name you entered") is a well-known person or character, such as Selena Gomez or Harry Potter, set this switch to ON. \n\nA good rule of thumb is if you can search them on google and they're in the top couple results, they are famous."), dismissButton: .default(Text("Okay")))
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
