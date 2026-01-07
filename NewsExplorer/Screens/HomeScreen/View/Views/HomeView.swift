//
//  HomeView.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 8/1/26.
//

import UIKit

class HomeView: UIView {
    
    let refreshControl = UIRefreshControl()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        return tableView
    }()
    
    lazy var spinnerView: UIView = {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 64))
        let spinner = UIActivityIndicatorView()
        spinner.center = footer.center
        footer.addSubview(spinner)
        spinner.startAnimating()
        
        return footer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        setupTableView()
        backgroundColor = .white
    }

    private func setupTableView() {
        addSubview(tableView)
        configureTableView()
        tableView.pinToEdges(of: self)
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
}
