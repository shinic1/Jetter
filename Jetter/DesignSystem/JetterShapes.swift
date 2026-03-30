//
//  JetterShapes.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

struct ArcPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        return path
    }
}

struct SleepWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let baseline = h * 0.3

        path.move(to: CGPoint(x: 0, y: baseline))

        // Descend into deep sleep
        path.addCurve(
            to: CGPoint(x: w * 0.4, y: h * 0.9),
            control1: CGPoint(x: w * 0.15, y: baseline),
            control2: CGPoint(x: w * 0.25, y: h * 0.85)
        )

        // Rise through REM
        path.addCurve(
            to: CGPoint(x: w * 0.7, y: h * 0.15),
            control1: CGPoint(x: w * 0.55, y: h * 0.95),
            control2: CGPoint(x: w * 0.6, y: h * 0.2)
        )

        // Return to light sleep
        path.addCurve(
            to: CGPoint(x: w, y: baseline),
            control1: CGPoint(x: w * 0.8, y: h * 0.1),
            control2: CGPoint(x: w * 0.9, y: baseline)
        )

        return path
    }
}

struct GaugeArcShape: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(180 + 180 * progress),
            clockwise: false
        )

        return path
    }
}
