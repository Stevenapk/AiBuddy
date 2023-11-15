//
//  LoginViewModel.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/22/23.
//

import Foundation
import SwiftUI
//#if !TEST_TARGET
import Firebase
import FirebaseAuth
import CryptoKit
import AuthenticationServices
//#endif

protocol LoginViewModelProtocol {
    var showError: Bool { get set }
    var errorMessage: String { get set }
    var logStatus: Bool { get set }
    var nonce: String { get set }
}

class LoginViewModel: ObservableObject, LoginViewModelProtocol {

    //MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    //MARK: App Log Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    //MARK: Apple Signin Properties
    @Published var nonce: String = ""
    
    //MARK: Error Handling
    func handleError(error: Error) {
        errorMessage = error.localizedDescription
        showError.toggle()
    }
    
    //MARK: Apple Signin Api
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential) {
        
        // Ensure token is retrieved
        guard let token = credential.identityToken else {
            return
        }
        
        // Ensure Token String is extrapolated
        guard let tokenString = String(data: token, encoding: .utf8) else {
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            if let err = err {
                // Handle Login Error
                self.handleError(error: err)
                return
            }
            
            //User Succesfully logged into firebase
            //Direct User to Home Page
            withAnimation(.easeInOut) {
                self.logStatus = true
            }
        }
    }
}

//MARK: Apple Signin Helpers
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashedString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    return hashedString
}


// MARK: - randomNonceString
/// Generates a random string of a specified length using a character set.
/// - Parameter length: The desired length of the random string (default is 32).
/// - Returns: A random string.
func randomNonceString(length: Int = 32) -> String {
    // Ensure the specified length is greater than 0
    precondition(length > 0)
    
    // Define a character set for the random string
    let charSet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
    // Initialize an empty string to store the result
    var result = ""
    // Initialize the remaining length to generate
    var remainingLength = length
    
    // Generate random bytes and map them to characters in the character set
    while remainingLength > 0 {
        let randoms: [UInt8] = (0...16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            
            // Check for errors in generating random bytes
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OS Status. \(errorCode)")
            }
            return random
        }
        
        // Append mapped characters to the result string
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            if random < charSet.count {
                result.append(charSet[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    // Return the generated random string
    return result
}
