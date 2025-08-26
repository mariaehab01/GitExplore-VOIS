//
//  GitHubService.swift
//  GitExplore
//

import Foundation

struct GitHubService {
    private let client = APIClient()

    func searchUsers(
        query: String,
        page: Int,
        sort: SearchUsersSort? = nil,
        order: SortOrder? = nil
    ) async throws -> SearchUsersResponse {
        try await client.get(
            Endpoints.searchUsers(query: query, page: page, sort: sort, order: order)
        )
    }
    
    func searchRepositories(query: String, page: Int) async throws -> SearchReposResponse {
        try await client.get(Endpoints.searchRepositories(query: query, page: page))
    }

    func userDetails(username: String) async throws -> UserDetails {
        try await client.get(Endpoints.userDetails(username: username))
    }

    func followers(username: String, page: Int) async throws -> [GitHubUser] {
        try await client.get(Endpoints.userFollowers(username: username, page: page))
    }
    
    func following(username: String, page: Int) async throws -> [GitHubUser] {
        try await client.get(Endpoints.userFollowing(username: username, page: page))
    }

    func repos(username: String, page: Int) async throws -> [Repo] {
        try await client.get(Endpoints.userRepos(username: username, page: page))
    }

    func starred(username: String, page: Int) async throws -> [Repo] {
        try await client.get(Endpoints.userStarred(username: username, page: page))
    }
    
}
