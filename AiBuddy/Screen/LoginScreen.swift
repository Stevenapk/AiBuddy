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
    var bgColor = Color(uiColor: #colorLiteral(red: 0.001054307795, green: 0.2363113165, blue: 0.2041468322, alpha: 1))
    var fgColor = Color(uiColor: #colorLiteral(red: 0.1794910729, green: 0.8994128108, blue: 0.9105356336, alpha: 1))
    var body: some View {
        ZStack {
            GradientBackgroundView()
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                    .frame(height: 160)
                HStack {
                    Spacer()
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)
                    Spacer()
                }
                .padding(.bottom, 40)
                .padding(.leading, -60)
                (Text("Welcome to DigiBud\nYour A.I. Messenger,").foregroundColor(.white) + Text("\nLogin to continue")
                    .foregroundColor(Color(uiColor: .lightGray)))
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineSpacing(10)
                    .padding(.top, 20)
                    .padding(.trailing, 15)
                
                Spacer()
                
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
                            .frame(width: 205, height: 55)
                            .blendMode(.overlay)
                        }
                        .clipped()
                    
                }
                .padding(.top, 60)
                .padding(.leading, -60)
                .frame(maxWidth: .infinity)
                Spacer()
                    .frame(height: 200)
            }
            .padding(.top)
            .padding(.leading, 60)
        }
        .ignoresSafeArea()
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
