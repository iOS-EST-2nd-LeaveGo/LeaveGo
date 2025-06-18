//
//  ImageCacheManager.swift
//  LeaveGo
//
//  Created by 박동언 on 6/18/25.
//

import Foundation
import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }

    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func fetchImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString

        if let cached = image(forKey: key) {
            return cached
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                setImage(image, forKey: key)
                return image
            }
        } catch {
            print("Image fetch error: \(error.localizedDescription)")
        }

        return nil
    }
}
