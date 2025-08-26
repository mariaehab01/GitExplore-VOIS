//
//  GiExploreApp.swift
//  GiExplore
//

import SwiftUI

struct AppRoot: View {
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView(isPresented: $showSplash)
            } else {
                MainTabView()
            }
        }
    }
}

