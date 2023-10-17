//
//  SearchBar.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/16/23.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String // Bind to a text property of the parent
    
    var body: some View {
        // Add text field for searching with a placeholder text
        TextField("Search", text: $text)
            .padding() // Add padding around the text field
            .background(Color(.systemGray6)) // Set background color
            .cornerRadius(10) // Round the corners of the text field
    }
}

