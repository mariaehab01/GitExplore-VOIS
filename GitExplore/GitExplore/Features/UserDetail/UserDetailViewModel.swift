//
//  UserDetailViewModel.swift
//  GitExplore
//

import Foundation

@MainActor
final class UserDetailViewModel: ObservableObject {
    enum LoadState {
        case idle
        case loading
        case loaded(UserDetails)
        case failed(String)
    }
    
    @Published var state: LoadState = .idle
    let username: String
    
    private let service = GitHubService()
    
    init(username: String) {
        self.username = username
    }
    
    func fetch() {
        guard case .idle = state else { return }
        state = .loading
        Task {
            do {
                let user = try await service.userDetails(username: username)
                state = .loaded(user)
            } catch {
                state = .failed((error as? LocalizedError)?.errorDescription
                                ?? "Something went wrong. Please try again.")
            }
        }
    }
}
