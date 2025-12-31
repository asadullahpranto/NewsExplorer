//
//  NewsAPIRepository.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 31/12/25.
//

import RxSwift

protocol NewsAPIRepository {
    func fetchArticles<T: Decodable>(query: String, fromDate: String, pageNo: Int) -> Single<T>
}
