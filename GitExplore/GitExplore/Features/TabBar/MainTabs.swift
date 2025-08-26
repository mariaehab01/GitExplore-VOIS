//
//  MainTabView.swift
//  GitExplore
//

import SwiftUI

struct MainTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            NavigationStack { FavoritesView() }   
                .tabItem { Label("Favorites", systemImage: "star.fill") }
                .tag(1)
        }
        .tint(.appAccent)
    }
}


