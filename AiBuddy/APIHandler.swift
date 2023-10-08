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
    
    @frozen enum Constants {
        static let key = "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"
    }
    
    private var client = OpenAISwift(config: .init(baseURL: "https://api.openai.com", endpointPrivider: OpenAIEndpointProvider(source: .openAI), session: .shared, authorizeRequest: { request in
        request.setValue("Bearer \(Constants.key)", forHTTPHeaderField: "Authorization")
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
    
    public func getResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {
        client.sendCompletion(with: input, completionHandler: { result in // Result<OpenAI, OpenAIError>
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
}
