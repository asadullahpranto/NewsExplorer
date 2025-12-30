//
//  NetworkError.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case apiError(Error)
    case invalidResponse
    case decodingError(Error)
    case unauthorized
    case unexpectedStatus
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .apiError(let error):
            return "API Error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server."
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized request."
        case .unexpectedStatus:
            return "Unexpected status code from server."
        case .unknown:
            return "Unknown error occurred."
        }
    }
}
