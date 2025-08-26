//
//  GitHubUser.swift
//  GitExplore
//
//  Created by Maria Ehab on 22/08/2025.
//

import Foundation

struct GitHubUser: Identifiable, Decodable, Hashable {
    let id: Int
    let username: String
    let avatarUrl: String

    private enum CodingKeys: String, CodingKey {
        case id
        case username = "login"
        case avatarUrl = "avatar_url"
    }
}

