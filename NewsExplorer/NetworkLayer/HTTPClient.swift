//
//  HTTPClient.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import Foundation

protocol HTTPClient {
    func makeRequest<T: Decodable>(endpoint: APIEndpoint, responseModel: T.Type) async throws -> T
}

extension HTTPClient {
    func makeRequest<T: Decodable>(endpoint: APIEndpoint, responseModel: T.Type) async throws -> T {
        
        // url building
        guard let url = prepareURL(from: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        request.allHTTPHeaderFields = endpoint.header
        
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    return decoded
                } catch {
                    throw NetworkError.decodingError(error)
                }
                
            case 401:
                throw NetworkError.unauthorized
                
            case 426:
                throw NetworkError.upgrationRequired
                
            default:
                throw NetworkError.unexpectedStatus
            }
            
        } catch let error as NetworkError {
            // If we already threw a NetworkError, propagate it
            throw error
        } catch {
            // Any other errors (like URLSession errors)
            throw NetworkError.apiError(error)
        }
    }
    
    func prepareURL(from endpoint: APIEndpoint) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.port = endpoint.port
        urlComponents.path = endpoint.path
        urlComponents.queryItems = endpoint.queryItems
        
        return urlComponents.url
    }
}

