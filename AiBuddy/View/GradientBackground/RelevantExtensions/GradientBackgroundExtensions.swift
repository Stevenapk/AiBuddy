//
//  GradientBackgroundExtensions.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/5/23.
//

import SwiftUI

extension View {
    func animatableGradient(fromGradient: Gradient, toGradient: Gradient, progress: CGFloat) -> some View {
        self.modifier(AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress))
    }
}
