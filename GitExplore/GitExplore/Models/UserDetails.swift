//
//  UserDetails.swift
//  GitExplore
//
//  Created by Maria Ehab on 22/08/2025.
//

import Foundation

struct UserDetails: Decodable {
    let username: String
    let name: String?
    let avatarUrl: String
    let bio: String?
    let followers: Int
    let following: Int
    let publicRepos: Int
    let company: String?
    let location: String?
    let createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case username   = "login"
        case name
        case avatarUrl  = "avatar_url"
        case bio
        case followers
        case following
        case publicRepos = "public_repos"
        case company
        case location
        case createdAt  = "created_at"
    }
}
