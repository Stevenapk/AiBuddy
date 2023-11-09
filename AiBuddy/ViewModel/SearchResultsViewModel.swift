//
//  SearchResultsViewModel.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

class SearchResultsViewModel: ObservableObject {

    @Published var searchText = ""
    @Published var selectedCharacter: Character? = nil
    @Published var selectedMessage: Message? = nil

}
