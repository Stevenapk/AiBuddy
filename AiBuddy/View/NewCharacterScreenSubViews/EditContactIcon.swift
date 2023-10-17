//
//  EditContactIcon.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/17/23.
//

import SwiftUI

struct EditContactIcon: View {
    
    @Binding var contactImage: UIImage?
    @Binding var name: String
    
    var body: some View {
        VStack {
            VStack {
                if contactImage == nil && !name.isEmpty {
                    ZStack {
                        
                        let firstInitial = String(name.prefix(1)).uppercased()
                        
                        
                        Circle()
                            .foregroundColor(getColorFor(initial: firstInitial))
                        Text(firstInitial)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                } else {
                    Image(uiImage: contactImage ?? UIImage(systemName: "person.crop.circle")!)
                        .resizable()
                        .clipShape(Circle())
                }
            }
            .frame(width: 100, height: 100)
            Text(contactImage != nil ? "Edit" : "Add")
                .font(.caption)
                .padding(4)
        }
    }
    
    //used for profile icon background color selection
    func getColorFor(initial: String) -> Color {
        switch initial.lowercased() {
        case "a", "b", "c", "d":
            return Color(hue: 0.1, saturation: 1.0, brightness: 0.8)
        case "e", "f", "g", "h":
            return Color(hue: 0.3, saturation: 1.0, brightness: 0.75)
        case "i", "j", "k", "l":
            return Color(hue: 0.5, saturation: 1.0, brightness: 0.75)
        case "m", "n", "o", "p":
            return Color(hue: 0.7, saturation: 1.0, brightness: 0.75)
        case "q", "r", "s", "t":
            return Color(hue: 0.99, saturation: 1.0, brightness: 0.75)
        case "u", "v", "w":
            return Color(hue: 0.75, saturation: 0.5, brightness: 0.75)
        case "x", "y", "z":
            return Color(hue: 0.0, saturation: 0.0, brightness: 0.3)
        default:
            return Color.black
        }
    }
}
