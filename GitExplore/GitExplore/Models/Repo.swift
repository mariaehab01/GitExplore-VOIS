//
//  Repo.swift
//  GitExplore
//
//  Created by Maria Ehab on 22/08/2025.
//

import Foundation

struct Repo: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let language: String?
    let htmlUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case stargazersCount = "stargazers_count"
        case forksCount      = "forks_count"
        case htmlUrl         = "html_url"
    }
}
