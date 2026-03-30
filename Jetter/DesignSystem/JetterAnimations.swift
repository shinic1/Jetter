//
//  JetterAnimations.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

enum JetterAnimations {
    static let cardEntry = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let timelineFill = Animation.easeOut(duration: 1.2)
    static let gaugeFill = Animation.easeOut(duration: 1.0)
    static let ringFill = Animation.easeOut(duration: 1.2)
    static let splashPlane = Animation.easeOut(duration: 1.0)
    static let splashFadeIn = Animation.easeIn(duration: 0.6)

    static func staggerDelay(index: Int) -> Animation {
        .spring(response: 0.5, dampingFraction: 0.8)
        .delay(Double(index) * 0.1)
    }

    static let pulse = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
}
