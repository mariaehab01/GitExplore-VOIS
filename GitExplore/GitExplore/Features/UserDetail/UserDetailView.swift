//
//  UserDetailView.swift
//  GitExplore
//

import SwiftUI
import SafariServices
import SwiftData

struct UserDetailView: View {
    @StateObject private var vm: UserDetailViewModel

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existing: [FavoriteUser]

    @State private var toastMessage: String? = nil
    @State private var showSafari = false
    @State private var safariURL: URL?
    @State private var isFav: Bool = false

    init(username: String) {
        _vm = StateObject(wrappedValue: UserDetailViewModel(username: username))
        _existing = Query(filter: #Predicate<FavoriteUser> { $0.username == username })
        _isFav = State(initialValue: !_existing.wrappedValue.isEmpty)
    }

    var body: some View {
        ZStack {
            VOISGradient().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    content
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
            }

            if let message = toastMessage {
                ToastView(message: message)
            }
        }
        .navigationTitle("Users • \(vm.username)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.surfaceSubtle, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                .tint(.appAccent)
            }
        }
        .task { vm.fetch() }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url).ignoresSafeArea()
            }
        }

    }

    // MARK: - Sections
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            loadingCard

        case .failed(let message):
            errorCard(message)

        case .loaded(let u):
            header(u)
            statsRow(u)
            infoCards(u)
            actions(u)
            Spacer(minLength: 8)
        }
    }

    private func header(_ u: UserDetails) -> some View {
        ZStack(alignment: .topLeading){
            VStack(spacing: 12) {
                AsyncImage(url: URL(string: u.avatarUrl)) { img in
                    img.resizable().scaledToFill()
                } placeholder: { ProgressView() }
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 5))
                    .shadow(color: .black.opacity(0.2), radius: 14, y: 8)
                
                Text(u.name ?? u.username)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color(.label))
                
                if let name = u.name, name.lowercased() != u.username.lowercased() {
                    Text("@\(u.username)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .center)
            let isFav = !existing.isEmpty
            Button {
                toggleFavorite(for: u, currentlyFav: isFav)
                showToast(isFav ? "User removed from favorites" : "User added to favorites")
            } label: {
                Image(systemName: isFav ? "star.fill" : "star")
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.appAccent)
                    .padding(12)
            }
            .padding([.top, .leading], 2)
            .accessibilityLabel(isFav ? "Unfavorite" : "Favorite")
        }
        .cardBackground()
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        
    }

    private func statsRow(_ u: UserDetails) -> some View {
        HStack(spacing: 12) {
            StatChip(system: "doc.on.doc", value: u.publicRepos)
                .scaledToFit()
            StatChip(system: "person.2", value: u.followers, label: "Followers")
                .frame(maxWidth: .infinity)
            StatChip(system: "person.crop.circle.badge.checkmark", value: u.following, label: "Following")
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
    }

    private func infoCards(_ u: UserDetails) -> some View {
        VStack(spacing: 14) {
            InfoCardRow(system: "calendar", text: "Joined \(dateString(u.createdAt))")
            if let company = u.company, !company.isEmpty {
                InfoCardRow(system: "building.2", text: company)
            }
            if let location = u.location, !location.isEmpty {
                InfoCardRow(system: "mappin.and.ellipse", text: location)
            }
            if let bio = u.bio, !bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio").font(.subheadline.weight(.semibold))
                    Text(bio).font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardBackground()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)

    }

    private func actions(_ u: UserDetails) -> some View {
        VStack(spacing: 12) {
            if let url = githubURL(for: u.username) {
                Button {
                    safariURL = url
                    showSafari = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "safari")
                        Text("Open on GitHub")
                            .underline()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .cardBackground()
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        
    }

    // MARK: - States

    private var loadingCard: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.2)
                .padding(.vertical, 28)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .center)
        .cardBackground()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text("Error").font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .center)
        .cardBackground()
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers
    private func toggleFavorite(for u: UserDetails, currentlyFav: Bool) {
        if currentlyFav, let current = existing.first {
            modelContext.delete(current)
        } else {
            let fav = FavoriteUser(
                username: u.username,
                avatarUrl: u.avatarUrl
            )
            modelContext.insert(fav)
        }
        try? modelContext.save()
        isFav = !currentlyFav
    }


    private func showToast(_ text: String) {
        withAnimation { toastMessage = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { toastMessage = nil }
        }
    }
}

// MARK: - Pieces

private struct StatChip: View {
    let system: String
    let value: Int
    var label: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: system)
            Text("\(value)")
            if let label { Text(label) }
        }
        .font(.footnote.weight(.semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.9)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Capsule().fill(Color.surfaceSubtle))
    }
}

private struct InfoCardRow: View {
    let system: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: system)
                .imageScale(.medium)
                .foregroundStyle(.secondary)
            Text(text).font(.body)
            Spacer()
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .center)
        .cardBackground()
    }
}


#Preview("User Detail") {
    NavigationStack {
        UserDetailView(username: "Moh")
    }
}
