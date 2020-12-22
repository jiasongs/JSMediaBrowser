//
//  DefaultWebImageMediator.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import SDWebImage

@objc(MediaBrowserViewDefaultWebImageMediator)
class DefaultWebImageMediator: NSObject, WebImageMediatorProtocol {

    func loadImage(url: URL?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?) -> Any? {
        return SDWebImageManager.shared.loadImage(with: url, options: SDWebImageOptions.refreshCached) { (receivedSize: Int, expectedSize: Int, targetURL) in
            if let progress = progress {
                progress(Int64(receivedSize), Int64(expectedSize))
            }
        } completed: { (image, data, error, cacheType, finished, targetURL) in
            if let completed = completed {
                completed(image, error, finished)
            }
        }
    }
    
    func cancelLoadImage(with data: Any) -> Bool {
        if let token = data as? SDWebImageCombinedOperation {
            token.cancel()
            return true
        }
        return false
    }
    
}
