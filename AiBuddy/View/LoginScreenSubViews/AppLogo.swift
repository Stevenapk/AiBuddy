//
//  AppLogo.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

// App Logo from project asset for use in login screen
struct AppLogo: View {
    var body: some View {
        HStack {
            Spacer()
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80)
            Spacer()
        }
    }
}
