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
    @Binding var isKeyboardShowing: Bool
    
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
                    if let contactImage {
                        Image(uiImage: contactImage)
                            .resizable()
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .foregroundColor(.primary)
                            .clipShape(Circle())
                    }
                }
            }
            .frame(width: isKeyboardShowing ? 50 : 105,
                   height: isKeyboardShowing ? 50 : 105)
            Text(contactImage != nil ? "Edit Photo" : "Add Photo")
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

struct EditContactIcon_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let refreshID = Binding<UUID>(get: {
                // Set random UUID as initial value
                return UUID()
            }, set: { newValue in
                // Handle the updated value here
            })
            NewCharacterScreen(refreshID: refreshID, viewModel: NewCharacterViewModel())
        }
    }
}
