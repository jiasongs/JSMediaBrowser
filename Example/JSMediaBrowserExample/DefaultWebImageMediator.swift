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

    func loadImage(url: URL?, progress: DownloadProgressBlock?, completed: CompletedBlock?) -> Any? {
        return SDWebImageManager.shared.loadImage(with: url, options: SDWebImageOptions(rawValue: 0)) { (receivedSize, expectedSize, targetURL) in
            if let progress = progress {
                progress(receivedSize, expectedSize)
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
