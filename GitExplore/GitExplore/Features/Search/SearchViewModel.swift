//
//  SearchViewModel.swift
//  GitExplore
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    // MARK: - Inputs
    @Published var query: String = ""
    @Published var sort: SearchUsersSort? = nil {didSet {if sort == nil { order = nil }}}
    @Published var order: SortOrder? = nil
    
    // MARK: - Outputs
    @Published private(set) var users: [GitHubUser] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published private(set) var lastTotalCount: Int? = nil  

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
        lastTotalCount = nil
        users.removeAll()
        errorMessage = nil

        Task { await loadNextPage(reset: true) }
    }

    func loadMoreIfNeeded(currentItem: GitHubUser?) {
        guard let currentItem, !isLoadingPage, !reachedEnd else { return }
        if currentItem.id == users.last?.id {
            Task { await loadNextPage() }
        }
    }

    // MARK: - Internals
    private var reachedEnd: Bool {
        totalCount > 0 && users.count >= totalCount
    }

    private func loadNextPage(reset: Bool = false) async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isLoadingPage, !q.isEmpty else { return }

        isLoadingPage = true
        if reset { isLoading = true }

        do {
            let resp = try await service.searchUsers(
                query: q,
                page: page,
                sort: sort,
                order: sort == nil ? nil : order
            )
            totalCount = resp.totalCount
            lastTotalCount = resp.totalCount
            users.append(contentsOf: resp.items)
            page += 1
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Something went wrong. Please try again."
        }

        isLoading = false
        isLoadingPage = false
    }
}
