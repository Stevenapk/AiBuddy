//
//  APIHandler.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import Foundation
import OpenAISwift

final class APIHandler {
    static let shared = APIHandler()
    
//    @frozen enum Constants {
        static let key = "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"
//    }
    
    private var client = OpenAISwift(config: .init(baseURL: "https://api.openai.com", endpointPrivider: OpenAIEndpointProvider(source: .openAI), session: .shared, authorizeRequest: { request in
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
}))
//    
//    private init() {}
//    
//    public func setup() {
//        let client = OpenAISwift(config: .init(baseURL: "https://api.openai.com", endpointPrivider: OpenAIEndpointProvider(source: .openAI), session: .shared, authorizeRequest: { request in
//            request.setValue("Bearer \(Constants.key)", forHTTPHeaderField: "Authorization")
//    }))
////        let client = OpenAISwift(authToken: Constants.key)
//    }
    
    //Send first single message -> called when creating a character or when character.sortedMessages.isEmpty
    public func getResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {

        print("INPUT \(input)")
        
        let responseLengths = [75, 100, 200, 400]
        
        client.sendCompletion(with: input,  maxTokens: responseLengths.randomElement()!, completionHandler: { result in // Result<OpenAI, OpenAIError>
                switch result {
                case .success(let model):
                    let output = model.choices?.first?.text ?? ""
                    print(output)
                    completion(.success(output))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
        })
    }
    
//    public func getResponseWithContext(input: String, character: Character, completion: @escaping (Result<String, Error>) -> Void) {
//
//        //format input
//        let input = character.promptWithContextFrom(input)
//
//        client.sendCompletion(with: input,  maxTokens: 540, completionHandler: { result in // Result<OpenAI, OpenAIError>
//                switch result {
//                case .success(let model):
//                    let output = model.choices?.first?.text ?? ""
//                    print(output)
//                    completion(.success(output))
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    completion(.failure(error))
//                }
//        })
//    }
    
    //Send first single message -> called when creating a character or when character.sortedMessages.isEmpty
//    public func getInitialResponse(input: String, character: Character, completion: @escaping (Result<String, Error>) -> Void) async {
//
//        do {
//            let chat: [ChatMessage] = [
//                ChatMessage(role: .system, content: "Act as \(character.promptPrefix)."),
//                ChatMessage(role: .user, content: input)
//            ]
//
//            let result = try await client.sendChat(
//                with: chat,
//                maxTokens: 540
//            )
//            // use result
//            let output = result.choices?.first?.message.content ?? ""
//            print(output)
//            completion(.success(output))
//        } catch {
//            // handle error getting result
//            print("ERROR GETTING RESULT")
//        }
//    }
    
    //send Message with chat context
    public func getResponseWithContext(input: String, character: Character, messages: [Message], completion: @escaping (Result<String, Error>) -> Void) async {
        
        print("YOOOOO")
        
        //filter message context to last 20
        let relevantMessages = messages.suffix(20)
        
        do {
            //define chat
            var chat: [ChatMessage] = [
                ChatMessage(role: .system, content: "Act as \(character.promptPrefix).")
            ]
            
            print("YO2")
            
            //append relevant messages to chat formatted to ChatMessage
            for message in relevantMessages {
                print("YO3")
                chat.append(ChatMessage(role: message.isSentByUser ? .user : .assistant, content: message.content))
            }
            
            print("About to append last one")
//            chat.append(contentsOf: relevantMessages.map({ChatMessage(role: $0.isSentByUser ? .user : .assistant, content: $0.content)}))
            if let lastChat = chat.last {
                if lastChat.content != input {
                    //append last input to chat
                    print("last chat not yet added but now will be. THIS SHOULD BE INCLUDED")
                    chat.append(ChatMessage(role: .user, content: input))
                } else {
                    print("last chat already added, THIS SHOULD NOT BE INCLUDED")
                }
            } else {
                print("No last CHAT")
            }
            
            print("about to AWAIT result")

            let result = try await client.sendChat(
                with: chat
//                maxTokens: 540
            )
            print("result is received!!!")
            // use result
            let output = result.choices?.first?.message.content ?? ""
            print(output)
            completion(.success(output))
        } catch let error {
            // handle error getting result
            print("ERROR GETTING RESULT \(error)")
        }
    }
}
