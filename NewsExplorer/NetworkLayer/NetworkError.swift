//
//  NetworkError.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import Foundation

enum NetworkError: LocalizedError { // Use LocalizedError instead of just Error
    case invalidURL
    case apiError(Error)
    case invalidResponse
    case decodingError(Error)
    case unauthorized
    case unexpectedStatus
    case upgrationRequired
    case unknown
    
    // The standard property for LocalizedError
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL format. Please try again."
        case .apiError(let error):
            return "Server connection issue: \(error.localizedDescription)"
        case .invalidResponse:
            return "The server sent an invalid response."
        case .decodingError(let error):
            // Professional tip: Don't show technical decoding errors to end users.
            // Log the 'error' to your console, but show a friendly message to the user.
            print("DEBUG: Decoding Error -> \(error)")
            return "We had trouble processing the data from the server."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .unexpectedStatus:
            return "Something went wrong on our end. Please try again later."
        case .upgrationRequired:
            return "You've reached the limit of the free tier. Please upgrade your plan!"
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
