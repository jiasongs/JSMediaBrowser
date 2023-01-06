//
//  SDWebImageMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import SDWebImage

public struct SDWebImageMediator: WebImageMediator {
    
    public func setImage(for view: UIView, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?) {
        /// 使用SDAnimatedImage, 用于动图显示
        let context: [SDWebImageContextOption: Any]? = [SDWebImageContextOption.animatedImageClass: SDAnimatedImage.self]
        view.sd_internalSetImage(with: url, placeholderImage: thumbImage, options: SDWebImageOptions.retryFailed, context: context, setImageBlock: { (image: UIImage?, data: Data?, cacheType: SDImageCacheType, targetUrl: URL?) in
            self.executeOnMainQueue {
                setImageBlock?(image, data)
            }
        }, progress: { (receivedSize: Int, expectedSize: Int, targetUrl: URL?) in
            self.executeOnMainQueue {
                progress?(Int64(receivedSize), Int64(expectedSize))
            }
        }, completed: { (image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, finished: Bool, url: URL?) in
            self.executeOnMainQueue {
                var cancelled: Bool = false
                if let error = error as NSError? {
                    cancelled = error.code == SDWebImageError.cancelled.rawValue
                }
                completed?(image, data, error as NSError?, cancelled, finished)
            }
        })
    }
    
    public func cancelImageRequest(for view: UIView) {
        view.sd_cancelCurrentImageLoad()
    }
    
    public init() {
        
    }
    
}

extension SDWebImageMediator {
    
    fileprivate func executeOnMainQueue(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async {
                work()
            }
        }
    }
    
}
