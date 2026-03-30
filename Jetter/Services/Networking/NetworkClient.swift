//
//  NetworkClient.swift
//  Jetter
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct Endpoint {
    let baseURL: String
    let path: String
    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var method: HTTPMethod = .get

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noData
    case rateLimited
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .httpError(let statusCode):
            return "Server returned status \(statusCode)"
        case .decodingError:
            return "Failed to parse response"
        case .noData:
            return "No data received"
        case .rateLimited:
            return "Too many requests"
        case .unauthorized:
            return "Invalid API key"
        }
    }
}

struct NetworkClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 15

        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        switch httpResponse.statusCode {
        case 204:
            throw NetworkError.noData
        case 200...299:
            break
        case 401, 403:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
