//
//  GradientBackgroundExtensions.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

extension View {
    // An extension to apply an animatable gradient to a view.
        /// - Parameters:
        ///   - fromGradient: The starting gradient.
        ///   - toGradient: The ending gradient.
        ///   - progress: The progress of the animation, ranging from 0.0 to 1.0.
        /// - Returns: A view with the specified animatable gradient applied.
    func animatableGradient(fromGradient: Gradient, toGradient: Gradient, progress: CGFloat) -> some View {
        self.modifier(AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress))
    }
}
