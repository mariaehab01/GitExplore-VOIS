//
//  CheckRow.swift
//  GitExplore
//

import SwiftUI

struct CheckRow: View {
    let title: String
    let selected: Bool

    var body: some View {
        HStack {
            if selected { Image(systemName: "checkmark") }
            Text(title)
            Spacer()
        }
    }
}
