//
//  APIError.swift
//  GitExplore
//

import Foundation

enum APIError: Error, LocalizedError {
    case server(Int)
    case decoding
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .server(let code):
            return "Server error (\(code)). Please try again."
        case .decoding:
            return "Couldn't read the server response."
        case .network:
            return "Network issue. Check your connection and try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
