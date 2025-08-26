//
//  Endpoints.swift
//  GitExplore
//

import Foundation

// MARK: - Type-safe options for search users
enum SearchUsersSort: String {
    case followers, repositories, joined
}

enum SortOrder: String {
    case asc, desc
}

enum Endpoints {
    private static let scheme = "https"
    private static let host   = "api.github.com"
    
    private static func make(path: String, items: [URLQueryItem] = []) -> URL {
            var comps = URLComponents()
            comps.scheme = scheme
            comps.host   = host
            comps.path   = path
            comps.queryItems = items.isEmpty ? nil : items
            return comps.url!
    }

    // MARK: - Users search & profile
    static func searchUsers(
        query: String,
        page: Int,
        sort: SearchUsersSort? = nil,
        order: SortOrder? = nil
    ) -> URL {
        var items: [URLQueryItem] = [
            .init(name: "q", value: query),
            .init(name: "page", value: String(page))
        ]
        if let sort {
            items.append(.init(name: "sort",  value: sort.rawValue))
            if let order {
                items.append(.init(name: "order", value: order.rawValue))
            }
        }
        return make(path: "/search/users", items: items)
    }
    
    
    static func searchRepositories(query: String, page: Int) -> URL {
        make(path: "/search/repositories",
             items: [
                .init(name: "q", value: query),
                .init(name: "page", value: String(page))
             ])
    }

    static func userDetails(username: String) -> URL {
        make(path: "/users/\(username)")
    }
    
    
    static func userFollowers(username: String, page: Int) -> URL {
        make(path: "/users/\(username)/followers",
             items: [ .init(name: "page", value: String(page)) ])
    }

    
    static func userFollowing(username: String, page: Int) -> URL {
        make(path: "/users/\(username)/following",
             items: [ .init(name: "page", value: String(page)) ])
    }
    
    
    static func userRepos(username: String, page: Int) -> URL {
        make(path: "/users/\(username)/repos",
             items: [
                .init(name: "page", value: String(page)),
                .init(name: "sort", value: "updated")
             ])
    }
    
    static func userStarred(username: String, page: Int) -> URL {
        make(path: "/users/\(username)/starred",
             items: [ .init(name: "page", value: String(page)) ])
    }

}

