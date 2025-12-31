//
//  ImageLoader.swift
//  NewsExplorer
//
//  Created by Asadullah Pranto on 31/12/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ImageLoader {
    
    static let shared = ImageLoader()
    
    private init() {}
    
    func loadImage(from urlString: String, targetSize: CGSize? = CGSize(width: 800, height: 450)) -> Observable<UIImage?> {
        // 1. Cache hit
        if let cached = ImageCache.shared.image(forKey: urlString) {
            return .just(cached)
        }
        
        guard let url = URL(string: urlString) else { return .just(nil) }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive)) // Run network on background
            .map { data -> UIImage? in
                return self.downsample(imageData: data, to: targetSize)
            }
            .do(onNext: { image in
                if let image = image {
                    ImageCache.shared.set(image, forKey: urlString)
                }
            })
            .observe(on: MainScheduler.instance) // Only switch to main for UI
            .catchAndReturn(nil)
            .share(replay: 1) // 🚀 Professional: Prevents multiple downloads for the same URL
    }
    
    private func downsample(imageData: Data, to pointSize: CGSize?) -> UIImage? {
        guard let pointSize = pointSize else { return UIImage(data: imageData) }
        
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return nil }
        
        // Calculate the scale (usually 2x or 3x for Retina displays)
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * UIScreen.main.scale
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        
        return UIImage(cgImage: downsampledImage)
    }
}

