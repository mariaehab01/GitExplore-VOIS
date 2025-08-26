//
//  DateFormatter.swift
//  GitExplore
//

import Foundation

extension DateFormatter {
    static let userJoined: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f
    }()
}
