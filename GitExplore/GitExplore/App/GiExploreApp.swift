//
//  GiExploreApp.swift
//  GiExplore
//

import SwiftUI

@main
struct GiExploreApp: App {
    var body: some Scene {
        WindowGroup {
            AppRoot()
        }
        .modelContainer(for: [FavoriteUser.self])
    }
}

