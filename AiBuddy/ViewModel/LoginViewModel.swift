//
//  LoginViewModel.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/22/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import CryptoKit
import AuthenticationServices

class LoginViewModel: ObservableObject {
    //MARK: View Properties
    
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    //MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    //MARK: App Log Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    //MARK: Apple Signin Properties
    @Published var nonce: String = ""
    
    //MARK: Error Handling
    func handleError(error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    //MARK: Apple Signin Api
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential) {
        
        //getting token
        guard let token = credential.identityToken else {
            print("error from firebase (getting token)")
            return
        }
        
        //Token String
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            if let error = err {
                print("LOGIN ERROR\(error.localizedDescription)")
                return
            }
            
            //User Succesfully logged into firebase
            print("Login Success!")
            //Directing User to Home Page
            withAnimation(.easeInOut) {
                self.logStatus = true
            }
        }
    }
}

//MARK: Extensions
extension UIApplication {
    //close keyboard from anywhere with UIApplication.shared.closeKeyboard() :)
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    //Root Controller
    func rootController() -> UIViewController {
        guard let window = connectedScenes.first as? UIWindowScene else {return .init()}
        guard let viewController = window.windows.last?.rootViewController else {return .init()}
        
        return viewController
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
