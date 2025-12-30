//
//  NewsAPI.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import Foundation

enum NewsAPI {
    case fetchArticles(query: String, fromDate: String)
}

extension NewsAPI: APIEndpoint {
    
    private var apiKey: String {
        return "4b5f5b6c89d44b958c912e6331031c29"
    }
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "newsapi.org"
    }
    
    var port: Int? {
        nil
    }
    
    var path: String {
        return "/v2/everything"
    }
    
    var httpMethod: HTTPMethod {
        .get
    }
    
    var header: [String : String] {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    var body: [String : Any]? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchArticles(let query, let fromDate):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "from", value: fromDate),
                URLQueryItem(name: "sortBy", value: "publishedAt"),
                URLQueryItem(name: "apiKey", value: apiKey)
            ]
        }
    }
}
