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
    
    func setImage(for view: UIView?, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?) {
        view?.sd_internalSetImage(with: url, placeholderImage: thumbImage, options: SDWebImageOptions.retryFailed, context: nil, setImageBlock: { (image: UIImage?, data: Data?, cacheType: SDImageCacheType, targetUrl: URL?) in
            if let setImageBlock = setImageBlock {
                setImageBlock(image, data)
            }
        }, progress: { (receivedSize: Int, expectedSize: Int, targetUrl: URL?) in
            if let progressBlock = progress {
                progressBlock(Int64(receivedSize), Int64(expectedSize))
            }
        }, completed: { (image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, finished: Bool, url: URL?) in
            if let completedBlock = completed {
                completedBlock(image, data, error, finished)
            }
        })
    }
    
    func cancelImageRequest(for view: UIView?) {
        view?.sd_cancelCurrentImageLoad()
    }
    
}
