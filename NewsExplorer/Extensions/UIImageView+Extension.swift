//
//  UIImageView+Extension.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 8/1/26.
//

import UIKit

extension UIImageView {
    
    /// Sets an image with a fade transition, similar to SDWebImage.
    /// - Parameters:
    ///   - image: The final image to display.
    ///   - placeholder: The image to show while the main image is "loading".
    ///   - animated: Whether to perform the cross-dissolve transition.
    func setImage(_ image: UIImage?, placeholder: UIImage? = nil, animated: Bool = true, duration: TimeInterval = 0.5) {
        // 1. If we have a placeholder and no final image yet, set placeholder immediately
        if image == nil {
            self.image = placeholder
            return
        }
        
        // 2. If animation is disabled, just set the image and exit
        guard animated else {
            self.image = image
            return
        }
        
        // 3. Perform the SDWebImage-style Cross Dissolve
        UIView.transition(
            with: self,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: {
                self.image = image
            },
            completion: nil
        )
    }
}

