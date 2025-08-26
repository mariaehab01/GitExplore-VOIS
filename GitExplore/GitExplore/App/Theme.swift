//
//  Theme.swift
//  GitExplore
//

import Foundation
import SwiftUI

// MARK: - Global theme helpers
struct VOISGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .appAccent, location: 0.00),
                .init(color: .appAccent, location: 0.32),
                .init(color: .appAccentSecondary, location: 1.00)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}


enum AppTheme {
    static let cornerRadius: CGFloat  = 16
    static let controlRadius: CGFloat = 14
}

struct CardBackground: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.cornerRadius
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.surfaceSubtle)
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
            )
    }
}

extension View {
    func cardBackground(cornerRadius: CGFloat = AppTheme.cornerRadius) -> some View {
        modifier(CardBackground(cornerRadius: cornerRadius))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                    .fill(Color.appAccent)
            )
            .foregroundStyle(.white)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous)
                    .stroke(Color.appAccentSecondary, lineWidth: 1.5)
            )
            .foregroundStyle(Color.appAccentSecondary)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
