//
//  LoginScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/22/23.
//

import SwiftUI
import AuthenticationServices
import Firebase
import FirebaseAuth

struct LoginScreen: View {
    @StateObject var loginModel: LoginViewModel = .init()
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Image(systemName: "triangle")
                .font(.system(size: 38))
                .foregroundColor(.indigo)
            (Text("Welcome,").foregroundColor(.black) + Text("\nLogin to continue").foregroundColor(.gray))
                .font(.title)
                .fontWeight(.semibold)
                .lineSpacing(10)
                .padding(.top, 20)
                .padding(.trailing, 15)
            
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
                                print("CALLED: SUCCESS GETTING RESULT")
                                print("success")
                                guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                    print("CALLED: ERROR WITH FIREBASE")
                                    print("error with firebase")
                                    return
                                }
                                loginModel.appleAuthenticate(credential: credential)
                            case .failure(let error):
                                print("CALLED: ERROR FAILURE ON COMPLETION IN SIGNIN BUTTON \(error)")
                            }
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 55)
                        .blendMode(.overlay)
                    }
                    .clipped()
                
            }
            .padding(.top, 60)
            .padding(.leading, -60)
            .frame(maxWidth: .infinity)
        Spacer()
        }
        .padding(.top)
            .padding(.leading, 60)
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
        }
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

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
