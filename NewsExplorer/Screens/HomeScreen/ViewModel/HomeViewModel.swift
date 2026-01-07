//
//  HomeViewModel.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import Foundation
import RxSwift
import RxRelay

class HomeViewModel {
    private let disposeBag = DisposeBag()
    let articles = BehaviorRelay<[Article]>(value: [])
    let isFetching = BehaviorRelay<Bool>(value: false)
    let isLastPage = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<String>()
    
    private let newsService: NewsAPIRepository
    
    var currentQuery: String = "apple"
    private var currentPage: Int = 1
    
    init(newsService: NewsAPIRepository) {
        self.newsService = newsService
    }
    
    func fetchArticles(fromDate: String = "2025-12-10", isRefresh: Bool = false) {
        if isRefresh {
            isLastPage.accept(false) // Reset on refresh
            currentPage = 1
        }
        
        // Don't fetch if already fetching OR if we reached the end
        guard !isFetching.value && !isLastPage.value else { return }
        
        isFetching.accept(true)
        
        newsService.fetchArticles(query: currentQuery, fromDate: fromDate, pageNo: currentPage)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (response: NewsResponse) in
                guard let self = self else { return }
                
                if response.articles.isEmpty {
                    self.isLastPage.accept(true)
                }
                
                let newArticles = response.articles
                if isRefresh {
                    self.articles.accept(newArticles)
                } else {
                    let currentArticles = self.articles.value
                    self.articles.accept(currentArticles + newArticles)
                }
                
                self.currentPage += 1 // Increment for next time
                self.isFetching.accept(false)
                
            } onFailure: { [weak self] error in
                self?.error.onNext(error.localizedDescription)
                self?.isFetching.accept(false)
            }
            .disposed(by: disposeBag)
    }
}
