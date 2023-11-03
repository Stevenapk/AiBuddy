//
//  GradientBackgroundView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 11/3/23.
//

import SwiftUI

struct AnimatableGradientModifier: AnimatableModifier {
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0
 
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
 
    func body(content: Content) -> some View {
        var gradientColors = [Color]()
 
        for i in 0..<fromGradient.stops.count {
            let fromColor = UIColor(fromGradient.stops[i].color)
            let toColor = UIColor(toGradient.stops[i].color)
 
            gradientColors.append(colorMixer(fromColor: fromColor, toColor: toColor, progress: progress))
        }
 
        return LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
 
    func colorMixer(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color {
        guard let fromColor = fromColor.cgColor.components else { return Color(fromColor) }
        guard let toColor = toColor.cgColor.components else { return Color(toColor) }
 
        let red = fromColor[0] + (toColor[0] - fromColor[0]) * progress
        let green = fromColor[1] + (toColor[1] - fromColor[1]) * progress
        let blue = fromColor[2] + (toColor[2] - fromColor[2]) * progress
 
        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

extension View {
    func animatableGradient(fromGradient: Gradient, toGradient: Gradient, progress: CGFloat) -> some View {
        self.modifier(AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress))
    }
}

struct GradientBackgroundView: View {
    @State private var progress: CGFloat = 0
      let gradient1 = Gradient(colors: [Color(uiColor: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)), Color(uiColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))])
      let gradient2 = Gradient(colors: [Color(uiColor: #colorLiteral(red: 0.1179298665, green: 0.1199498318, blue: 0.1210193056, alpha: 1)), Color(uiColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))])
    var body: some View {
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
