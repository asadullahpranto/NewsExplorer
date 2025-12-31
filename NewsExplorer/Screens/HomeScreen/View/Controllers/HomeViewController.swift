//
//  HomeViewController.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    private let refreshControl = UIRefreshControl()
    
    private func createFooterSpinner() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        return tableView
    }()
    
    private let viewModel = HomeViewModel(newsService: NewsAPIService())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        configureNavigationBar()
        setupTableView()
        bindViewModel()
    }
    
    private func configureNavigationBar() {
        title = "News Explorer"
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        configureTableView()
        tableView.pinToEdges(of: view)
    }
    
    private func configureTableView() {
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.className)
        tableView.separatorStyle = .none

        refreshControl.tintColor = .systemBlue
        refreshControl.attributedTitle = NSAttributedString(
            string: "Updating news...",
            attributes: [.font: UIFont.systemFont(ofSize: 12)]
        )
        
        tableView.refreshControl = refreshControl
    }
    
    private func bindViewModel() {
        // Bind articles to table view
        viewModel.articles
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items) { tableView, row, article in
                // Create cell with subtitle style
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.className) as! HomeTableViewCell
                cell.configure(with: article)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] cell, indexPath in
                guard let self = self else { return }
                
                let totalRows = self.tableView.numberOfRows(inSection: indexPath.section)
                
                // 🚀 Professional optimization: Trigger load when user is 3 rows from bottom
                // This makes the infinite scroll feel smoother (no waiting)
                // Modify the willDisplayCell logic
                if indexPath.row == totalRows - 1 && !viewModel.isLastPage.value {
                    self.viewModel.fetchArticles()
                }
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                // We pass isRefresh: true to reset the page count and clear the list
                self?.viewModel.fetchArticles(isRefresh: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.isFetching
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] fetching in
                guard let self = self else { return }
                
                if fetching {
                    // Only show footer if we aren't at page 1 (refreshing)
                    // and if we actually have data to append to
                    if !self.viewModel.articles.value.isEmpty && !self.refreshControl.isRefreshing {
                        self.tableView.tableFooterView = self.createFooterSpinner()
                    }
                } else {
                    // Logic to hide the footer with a slight delay for smooth UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !self.viewModel.isFetching.value {
                            self.tableView.tableFooterView = nil
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // This ensures the top spinner is ALWAYS in sync with the ViewModel
        viewModel.isFetching
            .observe(on: MainScheduler.instance)
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        
        // Handle row selection
        tableView.rx.modelSelected(Article.self)
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
        
        viewModel.fetchArticles()
    }

    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
