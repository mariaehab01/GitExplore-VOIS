//
//  APIClient.swift
//  GitExplore
//

import Foundation

struct APIClient {
    func get<T: Decodable>(
        _ url: URL,
        dateDecoding: JSONDecoder.DateDecodingStrategy = .iso8601
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("GitExplore (iOS)", forHTTPHeaderField: "User-Agent")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else { throw APIError.unknown }
            guard (200...299).contains(http.statusCode) else {
                throw APIError.server(http.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecoding
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding
            }
        } catch is URLError {
            throw APIError.network
        } catch is DecodingError {
            throw APIError.decoding
        } catch {
            throw APIError.unknown
        }
    }
}
