//
//  SearchReposResponse.swift
//  GitExplore
//
//  Created by Maria Ehab on 22/08/2025.
//

import Foundation

struct SearchReposResponse: Decodable {
    let totalCount: Int
    let items: [Repo]

    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
