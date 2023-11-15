//
//  GradientBackgroundView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/3/23.
//

import SwiftUI

// A view that displays a gradient background with animated color transition.
struct GradientBackgroundView: View {
    
    // Progress of the gradient transition
    @State private var progress: CGFloat = 0
    
    // Define the 2 separate gradients with 2 colors each (cool color scheme)
    let gradient1 = Gradient(colors: [Color(uiColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)), Color(uiColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))])
    let gradient2 = Gradient(colors: [Color(uiColor: #colorLiteral(red: 0.1179298665, green: 0.1199498318, blue: 0.1210193056, alpha: 1)), Color(uiColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))])
    
    var body: some View {
        // Create a rectangle with an animated gradient that plays on infinite loop
        Rectangle()
            .animatableGradient(fromGradient: gradient1, toGradient: gradient2, progress: progress)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: true)) {
                    self.progress = 1.0
                }
            }
    }
}

struct GradientBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        GradientBackgroundView()
    }
}
