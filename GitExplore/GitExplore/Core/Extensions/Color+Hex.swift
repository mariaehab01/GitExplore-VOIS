//
//  Color+Hex.swift
//  GitExplore
//

import Foundation
import SwiftUI

// MARK: - Hex initializer for SwiftUI Color
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF) / 255.0,
                  green: Double((hex >>  8) & 0xFF) / 255.0,
                  blue:  Double((hex >>  0) & 0xFF) / 255.0,
                  opacity: alpha)
    }
}

// MARK: - VOIS palette
extension Color {
    static let voisRed    = Color(hex: 0xE60000)
    static let voisPurple = Color(hex: 0x9C2AA0)
    static let voisGrey50 = Color(hex: 0xA6A6A6)
    static let voisGrey25 = Color(hex: 0xD2D2D2)
    static let voisGrey5  = Color(hex: 0xF2F2F2)
    static let voisGraphite = Color(hex: 0x4A4D4E)
}

// MARK: - Used VOIS theme colors
extension Color {
    static let appAccent = Color.voisRed
    static let appAccentSecondary = Color.voisPurple
    static let surfaceSoft = Color.voisGrey5
    static let surfaceSubtle = Color.white.opacity(0.9)
}

