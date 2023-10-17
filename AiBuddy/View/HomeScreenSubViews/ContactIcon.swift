//
//  ContactIcon.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/16/23.
//

import SwiftUI

struct ContactIcon: View {
    @Binding var character: Character // Character to display
    var width: CGFloat // Width and height of the icon
    
    var body: some View {
        VStack {
            // Check if the character has an image, if not, display initials
            if character.image == nil && !character.name.isEmpty {
                ZStack {
                    Circle()
                        .foregroundColor(character.colorForFirstInitial) // Circle background color
                    Text(character.firstInitial)
                        .foregroundColor(.white) // Text color
                        .font(.headline) // Text font size
                }
            } else {
                // Display character's image (if available)
                Image(uiImage: character.image ?? UIImage(systemName: "person.crop.circle")!)
                    .resizable()
                    .clipShape(Circle()) // Clip the image into a circle
            }
        }
        .frame(width: width, height: width) // Set the width and height of the icon
    }
}
