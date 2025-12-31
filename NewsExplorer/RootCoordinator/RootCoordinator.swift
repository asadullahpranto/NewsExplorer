//
//  RootCoordinator.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 31/12/25.
//

import UIKit

protocol RootCoordinator {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [RootCoordinator] { get set }
    func start()
}
