//
//  HomeView.swift
//  GitExplore
//

import SwiftUI
import Lottie

private enum SearchDomain: String, CaseIterable, Identifiable {
    case users = "Users"
    case repositories = "Repositories"
    var id: String { rawValue }
}

private struct GradientLogo: View {
    var imageName: String = "GitHubMark"
    var size: CGFloat = 200
    var title: String? = "GitExplore"
    var titleBottomPadding: CGFloat = -10
    var titleFontScale: CGFloat = 0.22
    
    var body: some View {
        VOISGradient()
            .mask(
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
            )
            .frame(width: size, height: size)
            .overlay(alignment: .bottom) {
                if let title {
                    VOISGradient()
                        .mask(
                            Text(title)
                                .font(.system(size: max(24, size * titleFontScale), weight: .heavy))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .padding(.horizontal, 12)
                                .frame(width: size)
                        )
                        .frame(width: size, height: max(24, size * titleFontScale), alignment: .bottom)
                        .padding(.bottom, titleBottomPadding)
                }
            }
            .accessibilityElement(children: .combine)
    }
}

struct HomeView: View {
    // Form
    @State private var query = ""
    @State private var domain: SearchDomain = .users
    @State private var userSort: SearchUsersSort? = nil
    @State private var userOrder: SortOrder? = nil
    
    // Navigation booleans
    @State private var goUsers = false
    @State private var goRepos = false
    
    // Carried params
    @State private var navQuery = ""
    @State private var navSort: SearchUsersSort? = nil
    @State private var navOrder: SortOrder? = nil
    
    // Force fresh destination each search
    @State private var usersIdentity = UUID()
    @State private var reposIdentity = UUID()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 28) {
                    Spacer(minLength: 24)
                    
                    // Brand
                    VStack() {
                        GradientLogo()
                        Text("Welcome…")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color(.label))
                            .accessibilityAddTraits(.isHeader)
                            .padding(.top, 8)
                        
                        Text("Find users or repositories here!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 8)
                    
                    // Domain selector
                    Picker("", selection: $domain) {
                        ForEach(SearchDomain.allCases) { d in Text(d.rawValue).tag(d) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .cardBackground()
                    .frame(maxWidth: .infinity)
                    
                    // Query + (users) filters + Search button
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass").padding().foregroundStyle(.secondary)
                            TextField(domain == .users ? "Enter username…" : "Search repositories…",
                                      text: $query)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .submitLabel(.search)
                            .onSubmit { startSearch() }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.surfaceSubtle))
                        
                        
                        if domain == .users {
                            HStack(spacing: 10) {
                                Menu {
                                    Section("Sort by") {
                                        Button { userSort = .joined; userOrder = .desc }  label: { CheckRow(title: "Joined", selected: userSort == .joined) }
                                        Button { userSort = .repositories; userOrder = .desc }  label: { CheckRow(title: "Repositories", selected: userSort == .repositories) }
                                        Button { userSort = .followers; userOrder = .desc }  label: { CheckRow(title: "Followers", selected: userSort == .followers) }
                                    }
                                    Button { userSort = nil; userOrder = nil } label: { CheckRow(title: "Best match", selected: userSort == nil) }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.up.arrow.down")
                                        Text(userSort?.rawValue.capitalized ?? "Best")
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    .font(.subheadline)
                                    .padding(.vertical, 9)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.appAccentSecondary.opacity(0.6), lineWidth: 1)
                                    )
                                }
                                
                                if userSort != nil {
                                    Menu {
                                        Button { userOrder = .desc } label: { CheckRow(title: "Descending", selected: (userOrder ?? .desc) == .desc) }
                                        Button { userOrder = .asc  } label: { CheckRow(title: "Ascending",  selected: userOrder == .asc) }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: (userOrder ?? .desc) == .desc ? "arrow.down" : "arrow.up")
                                            Text((userOrder ?? .desc).rawValue.uppercased())
                                        }
                                        .font(.subheadline)
                                        .padding(.vertical, 9)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.appAccentSecondary.opacity(0.6), lineWidth: 1)
                                        )
                                    }
                                }
                                
                                Spacer()
                                
                                Button("Search") { startSearch() }
                                    .buttonStyle(PrimaryButtonStyle())
                                    .frame(minWidth: 110)
                            }
                        } else {
                            HStack {
                                Spacer()
                                Button("Search") { startSearch() }
                                    .buttonStyle(PrimaryButtonStyle())
                                    .frame(minWidth: 110)
                            }
                        }
                    }
                    .cardBackground()
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .navigationDestination(isPresented: $goUsers) {
                SearchView(query: navQuery, sort: navSort, order: navOrder)
                    .id(usersIdentity)
            }
            .navigationDestination(isPresented: $goRepos) {
                let vm = SearchReposViewModel()
                ReposResultsView(vm: vm, headerText: "Repos • \(navQuery)")
                    .task { vm.query = navQuery; vm.submitSearch() }
                    .id(reposIdentity)
            }
            .onChange(of: goUsers) { old, new in if old && !new { resetForm() } }
            .onChange(of: goRepos) { old, new in if old && !new { resetForm() } }
            .navigationBarTitleDisplayMode(.inline)
            .tint(.appAccent)
        }
    }
    
    // MARK: - Actions
    private func startSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        
        navQuery = q
        navSort  = userSort
        navOrder = (userSort == nil) ? nil : userOrder
        
        switch domain {
        case .users:
            usersIdentity = UUID()
            goUsers = true
        case .repositories:
            reposIdentity = UUID()
            goRepos = true
        }
    }
    
    private func resetForm() {
        query = ""
        userSort = nil
        userOrder = nil
    }
}

#Preview { HomeView() }
