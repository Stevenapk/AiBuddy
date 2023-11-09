//
//  LoginScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/22/23.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginScreen: View {
    
    @EnvironmentObject var persistenceController: PersistenceController
    @StateObject var loginModel: LoginViewModel = .init()    
    var bgColor = Color(uiColor: #colorLiteral(red: 0.001054307795, green: 0.2363113165, blue: 0.2041468322, alpha: 1))
    var fgColor = Color(uiColor: #colorLiteral(red: 0.1794910729, green: 0.8994128108, blue: 0.9105356336, alpha: 1))
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                    .frame(height: 160)
                AppLogo()
                .padding(.bottom, 40)
                .padding(.leading, -60)
                WelcomeTextView()
                Spacer()
                CustomAppleSigninButton(loginModel: loginModel)
                Spacer()
                    .frame(height: 200)
            }
            .padding(.top)
            .padding(.leading, 60)
        }
        .ignoresSafeArea()
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
        }
        .alert(item: $persistenceController.persistentStoreError) { persistentStoreError in
            // Present an alert based on the error
            Alert(
                title: Text("Error"),
                message: Text(persistentStoreError.error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }

}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
