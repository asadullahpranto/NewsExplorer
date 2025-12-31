//
//  APIService.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import Foundation
import RxSwift

protocol NewsAPIRepository {
    func fetchArticles<T: Decodable>(query: String, fromDate: String, pageNo: Int) -> Single<T>
}

final class NewsAPIService: NewsAPIRepository, HTTPClient {
    
    func fetchArticles<T: Decodable>(query: String, fromDate: String = "2025-12-05", pageNo: Int = 1) -> Single<T> {
        return Single.create { single in
            Task {
                do {
                    let result: T = try await self.makeRequest(endpoint: NewsAPI.fetchArticles(query: query, fromDate: fromDate, pageNo: pageNo), responseModel: T.self)
                    single(.success(result))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
