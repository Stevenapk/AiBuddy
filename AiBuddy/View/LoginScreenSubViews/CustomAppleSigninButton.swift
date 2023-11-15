//
//  CustomAppleSigninButton.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI
import AuthenticationServices

struct CustomAppleSigninButton: View {
    
    @ObservedObject var loginModel: LoginViewModel
    
    var body: some View {
        VStack {
            // MARK: Custom Apple Signin Button
            CustomButton()
                .overlay {
                    SignInWithAppleButton { request in
                        
                        // Request parameters from apple login
                        loginModel.nonce = randomNonceString()
                        request.requestedScopes = [.email, .fullName]
                        request.nonce = sha256(loginModel.nonce)
                        
                    } onCompletion: { result in
                        // Handle success or failure after Apple login attempt
                        switch result {
                        case .success(let user):
                            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                return
                            }
                            // Call method to authenticate using Apple credentials
                            loginModel.appleAuthenticate(credential: credential)
                        case .failure:
                            return
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(width: 205, height: 55)
                    .blendMode(.overlay)
                }
                .clipped()
        }
        .padding(.top, 60)
        .padding(.leading, -60)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func CustomButton() ->  some View {
        HStack {
            // Apple logo image
            Image(systemName: "applelogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(height: 45)
            // "Login with Apple" text
            Text("Login with Apple")
                .font(.title2)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 15)
        .background {
            // Black rounded rectangle background
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}
