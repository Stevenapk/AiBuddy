//
//  HomeScreenViewModel.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/18/23.
//

import SwiftUI

class HomeScreenViewModel: ObservableObject {
    
    @Published var searchText = "" // Text for searching characters
    @Published var selectedCharacter: Character? = nil // Selected character for detailed view
    @Published var characterToEdit: Character? = nil // Character to edit
    @Published var showingNewCharacterScreen = false // Flag to show new character screen
    @Published var showingSearchResultsScreen = false // Flag to show search results screen
    @Published var selectedActionSheet: ActionSheetType? // Selected action sheet type
    
    // Enum for different action sheet types
    enum ActionSheetType: Identifiable {
        case deleteMessages(Character)
        case deleteCharacter(Character)
        
        var id: Int {
            // Generate a unique identifier for each case
            switch self {
            case .deleteMessages:
                return 1
            case .deleteCharacter:
                return 2
            }
        }
    }
    
    init() {
    }
    
    func rollForRandomNewMessage(from character: Character, completion: @escaping (Bool) -> Void) {
        
//        let probability = Int.random(in: 0..<9)
        
        let probability = 1
        
        if probability == 1 {
            // Select a random character
            character.receiveRandomMessage(completion: { success in
                completion(success)
            })
        }
    }
    
}
