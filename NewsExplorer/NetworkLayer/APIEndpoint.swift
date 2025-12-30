//
//  NetworkEndpoint.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import Foundation

protocol APIEndpoint {
    var scheme: String { get }
    var host: String { get }
    var port: Int? { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var header: [String: String] { get }
    var body: [String: Any]? { get }
    var queryItems: [URLQueryItem]? { get }
}
