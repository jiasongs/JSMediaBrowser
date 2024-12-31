//
//  SDWebImageMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import SDWebImage

public struct SDWebImageMediator: WebImageMediator {
    
    public var options: SDWebImageOptions
    public var context: [SDWebImageContextOption: Any]?
    
    public func setImage(
        for view: UIView,
        url: URL?,
        thumbImage: UIImage?,
        setImageBlock: WebImageMediatorSetImageBlock?,
        progress: WebImageMediatorDownloadProgress?,
        completed: WebImageMediatorCompleted?
    ) {
        view.sd_internalSetImage(
            with: url,
            placeholderImage: thumbImage,
            options: self.options,
            context: self.context,
            setImageBlock: { (image: UIImage?, data: Data?, cacheType: SDImageCacheType, targetUrl: URL?) in
                self.executeOnMainQueue {
                    setImageBlock?(image)
                }
            },
            progress: { (receivedSize: Int, expectedSize: Int, targetUrl: URL?) in
                self.executeOnMainQueue {
                    progress?(Int64(receivedSize), Int64(expectedSize))
                }
            },
            completed: { (image: UIImage?, data: Data?, error: Error?, cacheType: SDImageCacheType, finished: Bool, url: URL?) in
                self.executeOnMainQueue {
                    let nsError = error as? NSError
                    if let nsError = nsError {
                        let webImageError = WebImageError(error: nsError, cancelled: nsError.code == SDWebImageError.cancelled.rawValue)
                        completed?(.failure(webImageError))
                    } else {
                        let webImageResult = WebImageResult(image: image, data: data, url: url)
                        completed?(.success(webImageResult))
                    }
                }
            })
    }
    
    public func cancelImageRequest(for view: UIView) {
        view.sd_cancelLatestImageLoad()
    }
    
    public init(options: SDWebImageOptions? = nil, context: [SDWebImageContextOption: Any]? = nil) {
        self.options = options ?? [.retryFailed]
        self.context = context
    }
    
}

extension SDWebImageMediator {
    
    private func executeOnMainQueue(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async {
                work()
            }
        }
    }
    
}
