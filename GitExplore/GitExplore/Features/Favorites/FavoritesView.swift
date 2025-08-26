//
//  FavoritesView.swift
//  GitExplore
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: [SortDescriptor(\FavoriteUser.addedAt, order: .reverse)])
    private var favorites: [FavoriteUser]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if favorites.isEmpty {
                EmptyFavorites()
                    .padding(.horizontal, 24)
            } else {
                List {
                    ForEach(favorites) { fav in
                        NavigationLink(value: fav.username) {
                            FavoriteRow(fav: fav)
                                .modifier(CardBackground())
                        }
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            if !favorites.isEmpty { EditButton() }
        }
        .navigationDestination(for: String.self) { username in
            UserDetailView(username: username)
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { context.delete(favorites[i]) }
        try? context.save()
    }
}

private struct FavoriteRow: View {
    let fav: FavoriteUser

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: fav.avatarUrl)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure(_):
                    Image(systemName: "person.crop.square")
                        .resizable().scaledToFit()
                        .padding(10)
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(width: 52, height: 52)                           
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
            )

            Text(fav.username)
                .font(.headline)
                .foregroundStyle(Color(.label))

            Spacer()
        }
    }
}

private struct EmptyFavorites: View {
    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 24)
            Image(systemName: "star.circle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.appAccent, Color.appAccent.opacity(0.15))
                .font(.system(size: 96, weight: .semibold))
            Text("No favorites yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color(.label))
            Text("Tap the red star on a user to save them here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
