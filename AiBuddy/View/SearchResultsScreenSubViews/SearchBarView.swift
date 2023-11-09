//
//  SearchBarView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct SearchBarView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SearchResultsViewModel
    @FocusState var showKeyboard: Bool

    var body: some View {
        HStack {
            SearchBar(text: $viewModel.searchText, showKeyboard: _showKeyboard)

            Button("Cancel") {
                // Dismiss to HomeScreen
                dismiss()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 15)
    }
}
