//
//  SearchReposViewModel.swift
//  GitExplore
//

import Foundation
import Combine

@MainActor
final class SearchReposViewModel: ObservableObject {
    // MARK: - Inputs
    @Published var query: String = ""

    // MARK: - Outputs
    @Published private(set) var repos: [Repo] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Paging
    private var page: Int = 1
    private var totalCount: Int = 0
    private var isLoadingPage = false

    // MARK: - Dependencies
    private let service: GitHubService
    init(service: GitHubService = GitHubService()) { self.service = service }

    // MARK: - Public API
    func submitSearch() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        page = 1
        totalCount = 0
        repos.removeAll()
        errorMessage = nil

        Task { await loadNextPage(reset: true) }
    }

    func loadMoreIfNeeded(currentItem: Repo?) {
        guard let currentItem, !isLoadingPage, !reachedEnd else { return }
        if currentItem.id == repos.last?.id {
            Task { await loadNextPage() }
        }
    }

    private var reachedEnd: Bool {
        totalCount > 0 && repos.count >= totalCount
    }

    private func loadNextPage(reset: Bool = false) async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isLoadingPage, !q.isEmpty else { return }

        isLoadingPage = true
        if reset { isLoading = true }

        do {
            let resp = try await service.searchRepositories(query: q, page: page)
            totalCount = resp.totalCount
            repos.append(contentsOf: resp.items)
            page += 1
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Something went wrong. Please try again."
        }

        isLoading = false
        isLoadingPage = false
    }
}
