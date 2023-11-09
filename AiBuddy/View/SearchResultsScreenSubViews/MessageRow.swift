//
//  MessageRow.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct MessageRow: View {
    
    var message: Message
    var lettersToHighlight: String

    var body: some View {
        HStack {
            //display letters if they have no contact image, but have a name
            if message.character.image == nil && !message.character.name.isEmpty {
                ZStack {
                    Circle()
                        .foregroundColor(message.character.colorForFirstInitial)
                        .frame(width: 50, height: 50)
                    Text(message.character.firstInitial)
                        .foregroundColor(.white)
                        .font(.headline)
                }
            } else {
                Image(uiImage: message.character.image ?? UIImage(systemName: "person.crop.circle")!)
                    .resizable()
                    .frame(width: 52.375, height: 52.375)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text(message.character.name)
                    .font(.headline)
                Text(message.content.highlighted(letters: lettersToHighlight))
                    .font(.system(size: 15))
                    .lineLimit(4) // Limit text to 4 lines
            }
        }
    }
}
