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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
    }
    
    private func bindViewModel() {
        // Bind articles to table view
        viewModel.articles
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items) { tableView, row, article in
                // Create cell with subtitle style
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.className) as! HomeTableViewCell
                cell.configure(with: article)
                
//                if let imageUrl = article.urlToImage {
//                    ImageLoader.shared.loadImage(from: imageUrl, row: row) { [weak self] image in
//                        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? HomeTableViewCell {
//                            cell.articleImageView.image = image
//                        }
//                    }
//                }
                
                return cell
            }
            .disposed(by: disposeBag)

        
        // Handle row selection
        tableView.rx.modelSelected(Article.self)
            .subscribe(onNext: { article in
    
                let webVC = WebViewController()
                let webNavVC = UINavigationController(rootViewController: webVC)
                webNavVC.modalPresentationStyle = .fullScreen
                
                if let url = URL(string: article.url) {
                    webVC.articleURL = url
                    self.present(webNavVC, animated: true)
                }
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
        
        viewModel.fetchArticles(query: "apple")
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
