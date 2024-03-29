//
//  APIHandler.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import Foundation
import OpenAISwift

protocol APIHandlerProtocol {
    func getResponse(characterInfo: String, input: String, isAIBuddy: Bool, completion: @escaping (Result<String, Error>) -> Void)
}

final class APIHandler: APIHandlerProtocol {
    
    static let shared = APIHandler()
    
    //Send first single message -> called when creating a character or when character.sortedMessages.isEmpty
//    public func getResponse(input: String, isAIBuddy: Bool, completion: @escaping (Result<String, Error>) -> Void) {
//
//        getO { result in
//            if let gO = result {
//                // Use gO
//                let client = OpenAISwift(config: .init(baseURL: "https://api.openai.com", endpointPrivider: OpenAIEndpointProvider(source: .openAI), session: .shared, authorizeRequest: { request in
//                    request.setValue("Bearer \(gO)", forHTTPHeaderField: "Authorization")
//            }))
//
//                let responseLengths = [75, 100, 200, 400]
//
//                //always make longer response if it's the "AI Buddy" character
//                let maxTokens = isAIBuddy ? 800 : responseLengths.randomElement()!
//
//                client.sendCompletion(with: input,  maxTokens: maxTokens, completionHandler: { result in // Result<OpenAI, OpenAIError>
//                        switch result {
//                        case .success(let model):
//                            let output = model.choices?.first?.text ?? ""
//                            completion(.success(output))
//                        case .failure(let error):
//                            completion(.failure(error))
//                        }
//                })
//            } else {
//                // backend server retrieval issue occurred
//            }
//        }
//    }
    
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
            }
        }.resume()
    }
    
    //TODO: add the characterInfo as an input String for this func
    public func getResponse(characterInfo: String, input: String, isAIBuddy: Bool, completion: @escaping (Result<String, Error>) -> Void) {

        let responseLengths = [400, 800]
        
        //always make longer response if it's the "AI Buddy" character
        let maxTokens = isAIBuddy ? 800 : responseLengths.randomElement()!
        
        // Ensure valid cloud function url
        guard let url = URL(string: "https://us-central1-aibuddy-bfaf3.cloudfunctions.net/getO") else {
            return
        }
        
        // Request Data
        let requestData: [String: Any] = [
            "systemRole": characterInfo,
            "userInput": input,
            "maxTokens": maxTokens,
        ]
        
        // Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Retrieve response from servers
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(data != nil)
            if let data = data {
                let response = String(data: data, encoding: .utf8)
                completion(.success(response ?? ""))
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
        
    }
    
    func sendMessage(_ prompt: String, to character: Character, completion: @escaping (Result<Message, Error>) -> Void) {
        getResponse(characterInfo: character.sytemInfoForAI, input: prompt, isAIBuddy: character.name == "AI Buddy") { result in
            switch result {
            case .success(let output):

                //create message object from string output
                let message = Message(context: Constants.context)
                if !output.isEmpty {
                    message.content = output
                } else {
                    message.content = "..."
                }
                message.set(character)
                
                // Call the completion handler with the created message
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
//    func sendMessage(_ prompt: String, to character: Character, completion: @escaping (Result<Message, Error>) -> Void) {
//        APIHandler.shared.getResponse(input: prompt, isAIBuddy: character.name == "AI Buddy") { result in
//            switch result {
//            case .success(let output):
//
//                let formattedOutput = output.removeUnwantedLines
//
//                //create message object from string output
//                let message = Message(context: Constants.context)
//                if !formattedOutput.isEmpty {
//                    message.content = formattedOutput
//                } else {
//                    message.content = "..."
//                }
//                message.set(character)
//
//                // Call the completion handler with the created message
//                completion(.success(message))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
}

extension String {
    
    //removes blank lines and "." lines and returns output
    var removeUnwantedLines: String {
        // Split the input string into an array of lines
        let lines = self.split(separator: "\n")
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
}
