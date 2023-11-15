//
//  AboutTipsScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/11/23.
//

import SwiftUI

struct AboutTipsScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .opacity(0.9) // Semi-transparent background
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("At a glance:")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("The about section is where you describe additional aspects of the character.")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When to include:")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("If they’re famous (real or fictional), you do not need to type anything here, unless you wish to modify aspects of their personality or how they respond to you. If they're just a random jo, the AI will only know their name and no further details. In this case, including \"About\" details is required.")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What to include:")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("You can include anything from personal details (job or interests), to how they know or talk to you. You can also include anything you can imagine. This is where you train the AI who to be and how to talk to you. This can be as little as a couple words: “Licensed Therapist” or their whole life story. The choice is yours.")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding()
        }
        // Hide the default back button
        .navigationBarBackButtonHidden(true)
        
        // Provide a custom back button or view
        .navigationBarItems(leading:
                                Button(action: {
            // Dismiss: navigate back to last screen
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
            }
        }
        )
        .navigationTitle("\"About\" Tips")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct AboutTipsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AboutTipsScreen()
            .edgesIgnoringSafeArea(.all)
    }
}

