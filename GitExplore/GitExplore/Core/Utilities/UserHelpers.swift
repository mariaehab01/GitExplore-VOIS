//
//  UserHelpers.swift
//  GitExplore
//

import Foundation

func dateString(_ date: Date) -> String {
    DateFormatter.userJoined.string(from: date)
}

func githubURL(for username: String) -> URL? {
    URL(string: "https://github.com/\(username)")
}


