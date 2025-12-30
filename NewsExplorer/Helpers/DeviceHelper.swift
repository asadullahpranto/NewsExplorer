//
//  DeviceHelper.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 30/12/25.
//

import UIKit

final class DeviceHelper {
    class var isIpadDevice: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    class var isNotchedDevice: Bool {
        if UIDevice.current.hasNotch {
            return true
        }
        return false
    }
    
    class var safeAreaInsets: UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets
        }
        
        // Fallback if window isn't ready yet
        return UIEdgeInsets.zero
    }
    
    class var safeAreaTopInset: CGFloat {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        
        guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) else {
            return 0
        }
        
        let topPadding = window.safeAreaInsets.top
        return topPadding
    }
    
    class var safeAreaBottomInset: CGFloat {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        
        guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) else {
            return 0
        }
        
        let bottomPadding = window.safeAreaInsets.bottom
        return bottomPadding
    }
}
