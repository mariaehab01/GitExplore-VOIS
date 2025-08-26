//
//  NotFoundView.swift
//  GitExplore
//

import SwiftUI

struct NotFoundView: View {
    let title: String
    let subtitle: String
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 12)

            if let ui = UIImage(named: "Search-img") {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 240)
                    .accessibilityHidden(true)
            } else {
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(Color.voisGrey25.opacity(0.6))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundStyle(Color.appAccent)
                    )
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 6) {
                Text(title).font(.title3.bold()).foregroundStyle(Color(.label))
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }

            Button("Go back", action: onBack)
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 280)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
