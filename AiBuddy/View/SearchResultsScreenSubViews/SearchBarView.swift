//
//  SearchBarView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

// Search Bar and Cancel Button
struct SearchBarView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SearchResultsViewModel
    @FocusState var showKeyboard: Bool

    var body: some View {
        HStack {
            // Search Bar
            SearchBar(text: $viewModel.searchText, showKeyboard: _showKeyboard)
            
            // Cancel Button with dismiss to homescreen action
            Button("Cancel") {
                dismiss()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
    }
}
