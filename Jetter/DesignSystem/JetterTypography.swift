//
//  JetterTypography.swift
//  Jetter
//
//  Created by Nico Bourel on 1/29/26.
//

import SwiftUI

enum JetterTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 15, weight: .regular)
    static let subheadline = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .medium)
    static let caption2 = Font.system(size: 10, weight: .regular)
    static let monoTime = Font.system(size: 17, weight: .medium, design: .monospaced)
    static let monoLarge = Font.system(size: 28, weight: .bold, design: .monospaced)
}
