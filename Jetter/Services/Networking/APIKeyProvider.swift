//
//  APIKeyProvider.swift
//  Jetter
//

import Foundation

enum APIService: String {
    case aeroDataBox
}

struct APIKeyProvider {
    /// Reads the API key for the given service.
    ///
    /// The key is read from `APIKeys.plist` bundled with the app.
    /// To set up:
    /// 1. Copy `Configuration/APIKeys.plist.example` to `Configuration/APIKeys.plist`
    /// 2. Replace the placeholder value with your RapidAPI key
    static func apiKey(for service: APIService) -> String? {
        guard let url = Bundle.main.url(forResource: "APIKeys", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return nil
        }

        switch service {
        case .aeroDataBox:
            guard let apiKey = dict["AeroDataBoxKey"] as? String,
                  !apiKey.isEmpty,
                  apiKey != "YOUR_RAPIDAPI_KEY" else {
                return nil
            }

            return apiKey
        }
    }
}
