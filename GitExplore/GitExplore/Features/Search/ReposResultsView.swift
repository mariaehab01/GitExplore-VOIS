//
//  ReposResultsView.swift
//  GitExplore
//

import SwiftUI
import SafariServices

struct ReposResultsView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var vm: SearchReposViewModel
    var headerText: String

    @State private var showSafari = false
    @State private var safariURL: URL? = nil

    private var showNotFound: Bool {
        !vm.isLoading && vm.errorMessage == nil && vm.repos.isEmpty
    }

    var body: some View {
        ZStack {
            Group {
                if showNotFound {
                    Color(.systemBackground).ignoresSafeArea()
                } else {
                    VOISGradient().ignoresSafeArea()
                }
            }

            if showNotFound {
                NotFoundView(title: "No repositories found", subtitle: "Sorry, no repositories matched.", onBack: { dismiss() })
                .padding(.horizontal, 24)
            } else {
                List {
                    ForEach(vm.repos) { repo in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(repo.name).font(.headline)

                            if let d = repo.description, !d.isEmpty {
                                Text(d)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 12) {
                                Label("\(repo.stargazersCount)", systemImage: "star.fill")
                                    .font(.caption)
                                    .scaledToFill()

                                Label("\(repo.forksCount)", systemImage: "tuningfork")
                                    .font(.caption)
                                    .scaledToFill()

                                if let lang = repo.language {
                                    Text(lang)
                                        .font(.caption)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.surfaceSubtle))
                                        .scaledToFill()
                                }

                                Spacer()

                                if let url = URL(string: repo.htmlUrl) {
                                    Button {
                                        safariURL = url
                                        showSafari = true
                                    } label: {
                                        Text("Open")
                                            .font(.caption)
                                            .underline()
                                            .foregroundStyle(Color.appAccent)
                                            .padding(.vertical, 4)
                                            .scaledToFit()
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(10)
                        .cardBackground()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onAppear { vm.loadMoreIfNeeded(currentItem: repo) }
                    }

                    if vm.isLoading && !vm.repos.isEmpty {
                        HStack { Spacer(); ProgressView(); Spacer() }
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }

            if vm.isLoading && vm.repos.isEmpty && !showNotFound {
                ProgressView().scaleEffect(1.2)
            }
        }
        .navigationTitle(headerText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.surfaceSubtle, for: .navigationBar)
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
    }
}

#Preview {
    let vm = SearchReposViewModel()
    return NavigationStack {
        ReposResultsView(vm: vm, headerText: "Repos • demo")
    }
}
