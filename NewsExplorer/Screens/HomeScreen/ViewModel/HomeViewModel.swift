//
//  HomeViewModel.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import Foundation
import RxSwift

class HomeViewModel {
    private let disposeBag = DisposeBag()
    let articles = PublishSubject<[Article]>()
    let error = PublishSubject<String>()
    
    private let newsService: NewsAPIRepository
    
    init(newsService: NewsAPIRepository) {
        self.newsService = newsService
    }
    
    func fetchArticles(query: String, fromDate: String = "2025-12-05") {
        newsService.fetchArticles(query: query, fromDate: fromDate)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (response: NewsResponse) in
                self?.articles.onNext(response.articles)
            } onFailure: { [weak self] error in
                self?.error.onNext(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
}
