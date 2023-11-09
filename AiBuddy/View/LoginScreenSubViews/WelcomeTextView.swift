//
//  WelcomeTextView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct WelcomeTextView: View {
    var body: some View {
        (Text("Welcome to DigiBud\nYour A.I. Messenger,").foregroundColor(.white) + Text("\nLogin to continue")
            .foregroundColor(Color(uiColor: .lightGray)))
            .font(.title)
            .fontWeight(.semibold)
            .lineSpacing(10)
            .padding(.top, 20)
            .padding(.trailing, 15)
    }
}
