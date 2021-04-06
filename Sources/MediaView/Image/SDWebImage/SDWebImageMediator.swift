//
//  SDWebImageMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import SDWebImage

@objc(JSMediaBrowserViewSDWebImageMediator)
open class SDWebImageMediator: NSObject, WebImageMediatorProtocol {
    
    public func setImage(forView view: UIView?, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?) {
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
                var cancelled: Bool = false
                if let error = error as NSError? {
                    cancelled = error.code == SDWebImageError.cancelled.rawValue
                }
                completedBlock(image, data, error as NSError?, cancelled, finished)
            }
        })
    }
    
    public func cancelImageRequest(forView view: UIView?) {
        view?.sd_cancelCurrentImageLoad()
    }
    
}
