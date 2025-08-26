// FavoriteUser.swift
import Foundation
import SwiftData

@Model
final class FavoriteUser {
    @Attribute(.unique)
    var username: String
    var avatarUrl: String
    var userId: Int?
    var addedAt: Date           

    init(username: String, avatarUrl: String, addedAt: Date = .now) {
        self.username = username
        self.avatarUrl = avatarUrl
        self.addedAt = addedAt
    }
}
