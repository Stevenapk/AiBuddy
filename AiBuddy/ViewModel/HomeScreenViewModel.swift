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
        
        let probability = Int.random(in: 0...5)
        
        if probability == 1 {
            // Select a random character
            character.receiveRandomMessage(completion: { success in
                completion(success)
            })
        }
    }
    
}

extension HomeScreenViewModel {

    func createDefaultCharactersIfNeeded() {
        
        guard !hasUserOpenedAppBefore() else { return }
        
        let charactersData: [(name: String, promptPrefix: String, lastText: String, isFamous: Bool)] = [
            ("That 70's Guy", "a 17 year old friend from the era of the 1970's who responds in slang and loves to go dancing and to the movies", "Hey dude", false),
            ("Selena Gomez", "Selena Gomez", "Hey there", true),
            ("Motivational Speaker", "a motivational speaker who does his best to inspire you when times are hard and when you need encouragement", "Hello!", false),
            ("Licensed Therapist", "a licensed therapist who specializes in helping people deal with emotional issues and moving forward by giving people assignments when they ask for them to improve their emotional health. You prefer to not answer personal questions unless it's directly helpful to your clients because your conversations should be centered around the client and their problems and goals and hopes and dreams and them living a meaningful life. I am your client", "Hi! Let's work on you.", false),
            ("Professional Comedian", "A comedian who only responds either in puns or by insulting the person talking to him in a funny clever way", "Why hello there!", false)
        ]
        
        for data in charactersData {
            //create character
            let character = Character(context: Constants.context)
            character.name = data.name
            character.promptPrefix = data.promptPrefix
            character.isRecognizableName = data.isFamous
            
            //create your constant message
            let message = Message(context: Constants.context)
            message.isSentByUser = true
            message.content = "How's it going?"
            message.set(character)
            
            //create their variable message
            let response = Message(context: Constants.context)
            response.isSentByUser = false
            response.content = data.lastText
            response.set(character)
            
            character.addToMessages(message)
            character.addToMessages(response)
             
        }
        
        try? Constants.context.save()
    }
    
    func hasUserOpenedAppBefore() -> Bool {
        do {
            let appStatus = try Constants.context.fetch(AppStatus.fetchRequest())
            if !appStatus.isEmpty {
                print("CALLED: has opened app before: ALREADY EXIST")
                return true
            } else {
                print("CALLED: has not opened before; is EMPTTTTTYYYYY")
                let appStatus = AppStatus(context: Constants.context)
                appStatus.hasBeenOpenedBefore = true
                PersistenceController.shared.saveContext()
                return false
            }
        } catch {
            // Handle the error here (if any)
            print("Called: has not opened before, Error fetching AppStatus: \(error)")
            let appStatus = AppStatus(context: Constants.context)
            appStatus.hasBeenOpenedBefore = true
            PersistenceController.shared.saveContext()
            return false
        }
    }
}

