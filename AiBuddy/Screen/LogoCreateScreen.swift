//
//  LogoCreateScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/3/23.
//

import SwiftUI

struct LogoCreateScreen: View {
    var mod: CGFloat = 5
    var fgColor = Color(uiColor: #colorLiteral(red: 0.1794910729, green: 0.8994128108, blue: 0.9105356336, alpha: 1))
    var bgColor = Color(uiColor: #colorLiteral(red: 0.001054307795, green: 0.2363113165, blue: 0.2041468322, alpha: 1))
    var body: some View {
        ZStack {
            bgColor
            Image(systemName: "gear")
                .foregroundColor(fgColor)
                .offset(x: 11*mod, y: -14*mod)
                .font(.system(size: 20*mod))
            Image(systemName: "message.fill")
                .font(.system(size: 41*mod))
                .foregroundColor(bgColor)
            Image(systemName: "message")
                .font(.system(size: 42*mod))
                .foregroundColor(fgColor)
        }
        .offset(y: -100)
          
    }
}

struct LogoCreateScreen_Previews: PreviewProvider {
    static var previews: some View {
        LogoCreateScreen()
    }
}
