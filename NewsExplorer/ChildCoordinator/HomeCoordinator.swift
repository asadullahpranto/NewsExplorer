//
//  HomeCoordinator.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 31/12/25.
//

import UIKit

class HomeCoordinator: RootCoordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [RootCoordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeViewController = HomeViewController()
        homeViewController.coordinator = self
        self.navigationController.viewControllers = [homeViewController]
    }
    
    func showArticleDetail(_ article: Article) {
        guard let url = URL(string: article.url) else { return }
        
        let detailVC = WebViewController()
        detailVC.articleURL = url
        navigationController.pushViewController(detailVC, animated: true)
    }
}
