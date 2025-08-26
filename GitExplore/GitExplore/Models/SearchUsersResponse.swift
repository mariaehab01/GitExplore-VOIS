//
//  SearchUsersResponse.swift
//  GitExplore
//
//  Created by Maria Ehab on 22/08/2025.
//

import Foundation

struct SearchUsersResponse: Decodable {
    let totalCount: Int
    let items: [GitHubUser]

    private enum CodingKeys: String, CodingKey {
        case totalCount        = "total_count"
        case items
    }
}
