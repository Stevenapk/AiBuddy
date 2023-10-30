//
//  SearchBar.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/16/23.
//

import SwiftUI

struct SearchBar: View {
    @State var isTextFieldDisabled = false
    @Binding var text: String // Bind to a text property of the parent
    @FocusState var showKeyboard: Bool

    
    var body: some View {
        // Add text field for searching with a placeholder text
        
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(.systemGray6)) // Set background color
                .frame(height: 40)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .padding(.leading, 7.5)
                TextField("Search", text: $text)
                    .multilineTextAlignment(.leading) // Align text to leading
                    .padding(.trailing) // Add padding from right edge of screen
                    .disabled(isTextFieldDisabled)
                    .focused($showKeyboard)
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    
    static var previews: some View {
        let text = Binding<String>(get: {
            // Return your initial value here
            return ""
        }, set: { newValue in
            // Handle the updated value here
        })
        
        return SearchBar(text: text)
    }
}

