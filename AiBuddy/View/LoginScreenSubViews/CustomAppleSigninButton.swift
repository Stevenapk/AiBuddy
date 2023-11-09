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
            //MARK: Custom Apple Signin Button
            CustomButton()
                .overlay {
                    SignInWithAppleButton { request in
                        
                        //requesting parameters from apple login
                        loginModel.nonce = randomNonceString()
                        request.requestedScopes = [.email, .fullName]
                        request.nonce = sha256(loginModel.nonce)
                        
                    } onCompletion: { result in
                        //getting error or success
                        switch result {
                        case .success(let user):
                            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                return
                            }
                            loginModel.appleAuthenticate(credential: credential)
                        case .failure(let error):
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
                    Image(systemName: "applelogo")
                        .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(height: 45)
            Text("Login with Apple")
                .font(.title2)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}
