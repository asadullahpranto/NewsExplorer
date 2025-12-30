//
//  UIDevice+Extension.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import UIKit

extension UIDevice {
    var hasNotch: Bool {
        guard #available(iOS 11.0, *) else { return false }
        
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        
        guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) else {
            return false
        }
        
        let insets = window.safeAreaInsets
        
        // Treat “significant” insets as indicator of a notch or Dynamic Island
        let significantInset: CGFloat = 30
        return insets.top > significantInset || insets.left > 0 || insets.right > 0
    }
}
