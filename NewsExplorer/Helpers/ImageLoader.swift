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
    
    func loadImage(from urlString: String) -> Single<UIImage?> {
        
        // 1️⃣ Cache hit
        if let cached = ImageCache.shared.image(forKey: urlString) {
            return .just(cached)
        }
        
        // 2️⃣ Validate URL
        guard let url = URL(string: urlString) else {
            return .just(nil)
        }
        
        // 3️⃣ Download image
        return URLSession.shared.rx
            .data(request: URLRequest(url: url))   // Observable<Data>
            .map { UIImage(data: $0) }             // Observable<UIImage?>
            .do(onNext: { image in                  // Observable uses onNext
                if let image = image {
                    ImageCache.shared.set(image, forKey: urlString)
                }
            })
            .catchAndReturn(nil)                    // Observable operator
            .observe(on: MainScheduler.instance)
            .asSingle()                             // ✅ Convert to Single
    }
}

