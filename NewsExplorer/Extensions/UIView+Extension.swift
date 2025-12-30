//
//  UIView+.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import UIKit

extension UIView {
    func pinToEdges(of view: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
