//
//  SearchView.swift
//  GitExplore
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = SearchViewModel()

    @State private var selectedUser: GitHubUser? = nil

    @State private var didSubmit = false

    @State private var didSeed = false

    // Immutable inputs from Home
    let query: String
    let initialSort: SearchUsersSort?
    let initialOrder: SortOrder?

    init(query: String, sort: SearchUsersSort? = nil, order: SortOrder? = nil) {
        self.query = query
        self.initialSort = sort
        self.initialOrder = order
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .opacity(showNotFound ? 1 : 0)
            
            VOISGradient()
                .ignoresSafeArea()
                .opacity(showNotFound ? 0 : 1)

            if showNotFound {
                NotFoundView(
                    title: "User not found",
                    subtitle: "Sorry, the user was not found.",
                    onBack: { dismiss() }
                )
                .padding(.horizontal, 24)
            } else {
                List {
                    ForEach(vm.users) { user in
                        Button { selectedUser = user } label: {
                            UserRow(user: user).cardBackground()
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onAppear { vm.loadMoreIfNeeded(currentItem: user) }
                    }

                    if vm.isLoading && !vm.users.isEmpty {
                        HStack { Spacer(); ProgressView(); Spacer() }
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.top, 4)
            }

            if vm.isLoading && vm.users.isEmpty && !showNotFound {
                ProgressView().scaleEffect(1.2)
            }
        }
        .navigationTitle(
            query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Users"
            : "Users • \(query.trimmingCharacters(in: .whitespacesAndNewlines))"
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.surfaceSubtle, for: .navigationBar)
        .toolbar {
            if !vm.users.isEmpty {                          
                ToolbarItem(placement: .navigationBarTrailing) {
                    FilterMenu(sort: $vm.sort, order: $vm.order) {
                        didSubmit = true
                        vm.submitSearch()
                    }
                }
            }
        }
        .navigationDestination(item: $selectedUser) { user in
            UserDetailView(username: user.username)
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: { Text(vm.errorMessage ?? "") }
        .task {
            guard !didSeed else { return }
            didSeed = true
            vm.query = query
            vm.sort  = initialSort
            vm.order = initialSort == nil ? nil : initialOrder
            didSubmit = true
            vm.submitSearch()
        }
    }

    private var showNotFound: Bool {
        didSubmit &&
        vm.lastTotalCount == 0 &&
        !vm.isLoading &&
        vm.errorMessage == nil
    }
}

// MARK: - Filter menu

private struct FilterMenu: View {
    @Binding var sort: SearchUsersSort?
    @Binding var order: SortOrder?
    var onChange: () -> Void

    var body: some View {
        Menu {
            Section("Sort by") {
                Button { sort = .joined; order = .desc; onChange() } label: { CheckRow(title: "Joined",        selected: sort == .joined) }
                Button { sort = .repositories; order = .desc; onChange() } label: { CheckRow(title: "Repositories",  selected: sort == .repositories) }
                Button { sort = .followers; order = .desc; onChange() } label: { CheckRow(title: "Followers",     selected: sort == .followers) }
            }
            Button { sort = nil; order = nil; onChange() } label: {
                CheckRow(title: "Best match", selected: sort == nil)
            }

            if sort != nil {
                Section("Order") {
                    Button { order = .desc; onChange() } label: { CheckRow(title: "Descending", selected: (order ?? .desc) == .desc) }
                    Button { order = .asc;  onChange() } label: { CheckRow(title: "Ascending",  selected: order == .asc) }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .imageScale(.large)
                .foregroundStyle(.primary)
                .accessibilityLabel("Filters")
        }
    }
}

// MARK: - Fallback illustration

private struct MagnifierIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Color.voisGrey25.opacity(0.6))
                .scaleEffect(x: 1.2, y: 0.8)
                .offset(y: 20)
            Circle()
                .stroke(Color.appAccent, lineWidth: 16)
                .frame(width: 150, height: 150)
                .offset(x: -10, y: 10)
            Rectangle()
                .fill(Color.appAccent)
                .frame(width: 90, height: 18)
                .rotationEffect(.degrees(45))
                .offset(x: 85, y: 85)
            Circle().fill(Color.appAccent)
                .frame(width: 52, height: 52)
                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 10))
                .offset(x: 90, y: -20)
            Circle().fill(Color.appAccent)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 7))
                .offset(x: -30, y: 90)
        }
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

// MARK: - Row

struct UserRow: View {
    let user: GitHubUser
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: user.avatarUrl)) { img in
                img.resizable().scaledToFill()
            } placeholder: { ProgressView() }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.headline)
                Text("ID: \(user.id)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(8)
    }
}
// MARK: - Preview

#Preview {
    NavigationStack {
        SearchView(query: "mohamed")
    }
}
