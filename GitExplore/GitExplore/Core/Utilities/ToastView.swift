//
//  ToastView.swift
//  GitExplore
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.thinMaterial)
                .cornerRadius(16)
                .shadow(radius: 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 80)
        }
        .animation(.easeInOut, value: message)
    }
}

func showToast(_ message: String, toastMessage: Binding<String?>) {
    toastMessage.wrappedValue = message
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        withAnimation {
            toastMessage.wrappedValue = nil
        }
    }
}
