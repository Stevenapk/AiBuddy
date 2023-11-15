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
        
        //getting token
        guard let token = credential.identityToken else {
            return
        }
        
        //Token String
        guard let tokenString = String(data: token, encoding: .utf8) else {
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            if let err = err {
                //Login Error
                self.handleError(error: err)
                return
            }
            
            //User Succesfully logged into firebase
            //Directing User to Home Page
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

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    
    let charSet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0...16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OS Status. \(errorCode)")
            }
            return random
        }
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
    return result
}
