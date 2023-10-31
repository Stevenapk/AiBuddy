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
//        static let key = "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"
//    }
    
   
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
    public func getResponse(input: String, isAIBuddy: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        
        getO { result in
            if let gO = result {
                // Use gO
                print("CALLED5 KEY --  \(gO)")
                let client = OpenAISwift(config: .init(baseURL: "https://api.openai.com", endpointPrivider: OpenAIEndpointProvider(source: .openAI), session: .shared, authorizeRequest: { request in
                    request.setValue("Bearer \(gO)", forHTTPHeaderField: "Authorization")
            }))
                
                print("CALLED5 INPUT \(input)")
                
                let responseLengths = [75, 100, 200, 400]
                
                //always make longer response if it's the AI Buddy character
                let maxTokens = isAIBuddy ? 800 : responseLengths.randomElement()!
                
                client.sendCompletion(with: input,  maxTokens: maxTokens, completionHandler: { result in // Result<OpenAI, OpenAIError>
                        switch result {
                        case .success(let model):
                            let output = model.choices?.first?.text ?? ""
                            print(output)
                            print("CALLED5 WORKED \(output)")
                            completion(.success(output))
                        case .failure(let error):
                            print(error.localizedDescription)
                            print("CALLED5 RESPONSE DIDN'T WORK \(error)")
                            completion(.failure(error))
                        }
                })
                
            } else {
                // Handle error or nil result
            }
        }
    }
    
    func getO(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://us-central1-aibuddy-bfaf3.cloudfunctions.net/getO") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                if let gO = String(data: data, encoding: .utf8) {
                    completion(gO)
                } else {
                    completion(nil)
                }
            } catch {
                print(error.localizedDescription)
                completion(nil)
            }
        }.resume()
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
//    public func getResponseWithContext(input: String, character: Character, messages: [Message], completion: @escaping (Result<String, Error>) -> Void) async {
//
////        getO { result in
////            if let gO = result {
////                // Use gO
////                var client = OpenAISwift(config: .init(baseURL: "https://api.openai.com", endpointPrivider: OpenAIEndpointProvider(source: .openAI), session: .shared, authorizeRequest: { request in
////                    request.setValue("Bearer \(gO)", forHTTPHeaderField: "Authorization")
////            }))
////
////                //Code HERE
////
////            } else {
////                // Handle error or nil result
////            }
////        }
//
//        print("YOOOOO")
//
//        //filter message context to last 20
//        let relevantMessages = messages.suffix(20)
//
//        do {
//            //define chat
//            var chat: [ChatMessage] = [
//                ChatMessage(role: .system, content: "Act as \(character.promptPrefix).")
//            ]
//
//            print("YO2")
//
//            //append relevant messages to chat formatted to ChatMessage
//            for message in relevantMessages {
//                print("YO3")
//                chat.append(ChatMessage(role: message.isSentByUser ? .user : .assistant, content: message.content))
//            }
//
//            print("About to append last one")
////            chat.append(contentsOf: relevantMessages.map({ChatMessage(role: $0.isSentByUser ? .user : .assistant, content: $0.content)}))
//            if let lastChat = chat.last {
//                if lastChat.content != input {
//                    //append last input to chat
//                    print("last chat not yet added but now will be. THIS SHOULD BE INCLUDED")
//                    chat.append(ChatMessage(role: .user, content: input))
//                } else {
//                    print("last chat already added, THIS SHOULD NOT BE INCLUDED")
//                }
//            } else {
//                print("No last CHAT")
//            }
//
//            print("about to AWAIT result")
//
//            let result = try await client.sendChat(
//                with: chat
////                maxTokens: 540
//            )
//            print("result is received!!!")
//            // use result
//            let output = result.choices?.first?.message.content ?? ""
//            print(output)
//            completion(.success(output))
//        } catch let error {
//            // handle error getting result
//            print("ERROR GETTING RESULT \(error)")
//        }
//    }
    
    func sendMessage(_ prompt: String, to character: Character, completion: @escaping (Message?) -> Void) {
        APIHandler.shared.getResponse(input: prompt, isAIBuddy: character.name == "AI Buddy") { result in
            print("IS THIS AI BUDDY? \(character.name == "AI Buddy")")
            switch result {
            case .success(let output):
                
                //removes blank lines and "." lines and returns output
                func removeUnwantedLines(from input: String) -> String {
                    
                    // Split the input string into an array of lines
                    let lines = input.split(separator: "\n")
                    // Create an empty string to store the result
                    var result = ""
                    
                    for line in lines {
                        // Trim leading and trailing whitespaces from the line
                        let trimmedLine = line.trimmingCharacters(in: .whitespaces)

                        // If the response has no characters yet, and the proposed line isn't empty or a period
                        if result.isEmpty && !trimmedLine.isEmpty && trimmedLine != "." {
                            // Append the line to the result string!
                            result += "\(line)\n"
                        // If the result is not empty and the proposed line isn't a period
                        } else if trimmedLine != "." {
                            // Append the line to the result string!
                            result += "\(line)\n"
                        }
                    }

                    // Remove the last line if it is blank
                    if result.last == "\n" {
                        result.removeLast()
                    }

                    // Return the properly formatted result
                    return result
                }

                let formattedOutput = removeUnwantedLines(from: output)

                //create message object from string output
                let message = Message(context: Constants.context)
                if !formattedOutput.isEmpty {
                    message.content = formattedOutput
                } else {
                    message.content = "..."
                }
                message.set(character)

//                //save changes to core data
//                PersistenceController.shared.saveContext() //TODO: Uncomment this if weird sending message behavior :)
                
                // Call the completion handler with the created message
                completion(message)

//                        self.models.append(output)
//                        responseText = models.joined(separator: " ")
            case .failure(let error):
                print("CALLED5 RESPONSE failed \(error)")
                completion(nil)
            }
        }
    }
}
