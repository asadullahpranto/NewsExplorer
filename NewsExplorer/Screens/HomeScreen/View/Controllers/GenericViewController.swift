//
//  GenericViewController.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 8/1/26.
//

import UIKit

class GenericViewController<T: UIView>: UIViewController {
    
    public var rootView: T {
        return view as! T
    }
    
    override func loadView() {
        view = T()
    }
}
