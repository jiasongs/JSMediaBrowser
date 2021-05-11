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
    
    public func setImage(for imageView: UIImageView, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?) {
        /// 使用SDAnimatedImageView时, 一定要使用SDAnimatedImage, 否则将会是普通的UIImageView渲染
        var context: [SDWebImageContextOption: Any]? = nil
        if let _ = imageView as? SDAnimatedImageView {
            context = [SDWebImageContextOption.animatedImageClass: SDAnimatedImage.self]
        }
        imageView.sd_internalSetImage(with: url, placeholderImage: thumbImage, options: SDWebImageOptions.retryFailed, context: context, setImageBlock: { (image: UIImage?, data: Data?, cacheType: SDImageCacheType, targetUrl: URL?) in
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
    
    public func cancelImageRequest(for imageView: UIImageView) {
        imageView.sd_cancelCurrentImageLoad()
    }
    
}
