//
//  AnimatableGradientModifier.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

struct AnimatableGradientModifier: AnimatableModifier {
    
    // MARK: - Properties
    
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0
    
    // MARK: - Animatable Data
 
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
 
    
    // MARK: - Body
        /// Applies the gradient transition to the provided content.
        /// - Parameter content: The content to which the gradient transition is applied.
        /// - Returns: A view with the animated gradient background.
    func body(content: Content) -> some View {
        var gradientColors = [Color]()
 
        // Iterate through gradient stops and mix colors based on the progress value
        for i in 0..<fromGradient.stops.count {
            let fromColor = UIColor(fromGradient.stops[i].color)
            let toColor = UIColor(toGradient.stops[i].color)
 
            gradientColors.append(colorMixer(fromColor: fromColor, toColor: toColor, progress: progress))
        }
 
        // Create a linear gradient with mixed colors
        return LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    
    // MARK: - Color Mixing
        /// Mixes colors based on the progress value.
        /// - Parameters:
        ///   - fromColor: The starting color.
        ///   - toColor: The target color.
        ///   - progress: The progress value determining the mixing ratio.
        /// - Returns: The mixed color.
    func colorMixer(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color {
        // Ensure fromColor and toColor components exist
        guard let fromColor = fromColor.cgColor.components else { return Color(fromColor) }
        guard let toColor = toColor.cgColor.components else { return Color(toColor) }
 
        // Mix RGB components based on progress
        let red = fromColor[0] + (toColor[0] - fromColor[0]) * progress
        let green = fromColor[1] + (toColor[1] - fromColor[1]) * progress
        let blue = fromColor[2] + (toColor[2] - fromColor[2]) * progress
 
        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}
