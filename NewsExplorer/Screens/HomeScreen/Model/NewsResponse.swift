//
//  NewsResponse.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
