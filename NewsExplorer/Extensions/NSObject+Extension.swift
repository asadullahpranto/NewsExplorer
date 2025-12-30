//
//  NSObject+Extension.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import UIKit

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}
