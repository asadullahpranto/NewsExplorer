//
//  HomeViewController.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: GenericViewController<HomeView> {
    
    private let disposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    private let viewModel = HomeViewModel(newsService: NewsAPIService())
    
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupSearchController()
    }
    
    private func setupViews() {
        configureNavigationBar()
        bindViewModel()
    }
    
    private func configureNavigationBar() {
        title = "News Explorer"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func bindViewModel() {
        // Bind articles to table view
        viewModel.articles
            .observe(on: MainScheduler.instance)
            .bind(to: rootView.tableView.rx.items) { tableView, row, article in
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.className) as! HomeTableViewCell
                cell.configure(with: article)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self else { return }
                
                let fifteenDaysAgo = Calendar.current.date(byAdding: .day, value: -15, to: Date())!
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let totalRows = self.rootView.tableView.numberOfRows(inSection: indexPath.section)
                
                if indexPath.row == totalRows - 1 && !viewModel.isLastPage.value {
                    self.viewModel.fetchArticles(fromDate: formatter.string(from: fifteenDaysAgo))
                }
            })
            .disposed(by: disposeBag)
        
        rootView.refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                // We pass isRefresh: true to reset the page count and clear the list
                let fifteenDaysAgo = Calendar.current.date(byAdding: .day, value: -15, to: Date())!
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self?.viewModel.fetchArticles(fromDate: formatter.string(from: fifteenDaysAgo), isRefresh: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.isFetching
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] fetching in
                guard let self = self else { return }
                
                if fetching {
                    // Only show footer if we aren't at page 1 (refreshing)
                    // and if we actually have data to append to
                    if !self.viewModel.articles.value.isEmpty && !self.rootView.refreshControl.isRefreshing {
                        self.rootView.tableView.tableFooterView = self.rootView.spinnerView
                    }
                } else {
                    // Logic to hide the footer with a slight delay for smooth UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !self.viewModel.isFetching.value {
                            self.rootView.tableView.tableFooterView = nil
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // This ensures the top spinner is ALWAYS in sync with the ViewModel
        viewModel.isFetching
            .observe(on: MainScheduler.instance)
            .bind(to: rootView.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        
        // Handle row selection
        rootView.tableView.rx.modelSelected(Article.self)
            .subscribe(onNext: { [weak self] article in
                self?.coordinator?.showArticleDetail(article)
            })
            .disposed(by: disposeBag)
        
        // Handle errors
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.text
            .orEmpty
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)
        
//        viewModel.fetchArticles()
    }
    
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for articles..."
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}
