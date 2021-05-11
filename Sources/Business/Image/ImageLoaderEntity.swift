//
//  ImageLoaderEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import JSCoreKit

@objc(JSMediaBrowserImageLoaderEntity)
open class ImageLoaderEntity: BasisLoaderEntity, ImageLoaderProtocol {
    
    @objc public var webImageMediator: WebImageMediatorProtocol?
    
    @objc public func request(for imageView: UIImageView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) {
        if let sourceItem = self.sourceItem as? ImageSourceProtocol {
            /// 如果存在image, 且imageUrl为nil时, 则代表是本地图片, 无须网络请求
            if let image = sourceItem.image, sourceItem.imageUrl == nil {
                if let completed = completed {
                    JSAsyncExecuteOnMainQueue {
                        self.isFinished = true
                        completed(self, image, nil, nil, false, true)
                    }
                }
            } else {
                let url: URL? = sourceItem.imageUrl
                self.webImageMediator?.setImage(for: imageView, url: url, thumbImage: sourceItem.thumbImage, setImageBlock: { (image: UIImage?, imageData: Data?) in
                    if let setDataBlock = setDataBlock {
                        setDataBlock(self, image, imageData)
                    }
                }, progress: { (receivedSize: Int64, expectedSize: Int64) in
                    if let downloadProgress = downloadProgress {
                        JSAsyncExecuteOnMainQueue {
                            self.progress.completedUnitCount = receivedSize
                            self.progress.totalUnitCount = expectedSize
                            downloadProgress(self, self.progress)
                        }
                    }
                }, completed: { (image: UIImage?, imageData: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
                    self.error = error
                    if image != nil && error == nil && finished {
                        sourceItem.image = image
                    }
                    if let completed = completed {
                        JSAsyncExecuteOnMainQueue {
                            self.isFinished = finished
                            completed(self, image, imageData, error, cancelled, finished)
                        }
                    }
                })
            }
        }
    }
    
    public func cancelRequest(for imageView: UIImageView) {
        self.webImageMediator?.cancelImageRequest(for: imageView)
    }
    
}
