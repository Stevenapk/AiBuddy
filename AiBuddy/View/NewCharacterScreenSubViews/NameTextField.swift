//
//  NameTextField.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct NameTextField: View {
    @Binding var name: String

    var body: some View {
        TextField("Name", text: $name)
            .padding(7.5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
            )
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 5)
    }
}
