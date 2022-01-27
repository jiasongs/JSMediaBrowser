//
//  ImageLoaderEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import JSCoreKit

public class ImageLoaderEntity: ImageLoaderProtocol {
    
    public var sourceItem: SourceProtocol?
    public var progress: Progress = Progress()
    public var error: NSError?
    public var isFinished: Bool = false
    public var webImageMediator: WebImageMediator?
    
    public func request(for imageView: UIImageView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) {
        if var sourceItem = self.sourceItem as? ImageSourceProtocol {
            /// 如果存在image, 且imageUrl为nil时, 则代表是本地图片, 无须网络请求
            if let image = sourceItem.image, sourceItem.imageUrl == nil {
                JSAsyncExecuteOnMainQueue {
                    self.isFinished = true
                    completed?(self, image, nil, nil, false, true)
                }
            } else {
                let url: URL? = sourceItem.imageUrl
                self.webImageMediator?.setImage(for: imageView, url: url, thumbImage: sourceItem.thumbImage, setImageBlock: { (image: UIImage?, imageData: Data?) in
                    setDataBlock?(self, image, imageData)
                }, progress: { (receivedSize: Int64, expectedSize: Int64) in
                    JSAsyncExecuteOnMainQueue {
                        self.progress.completedUnitCount = receivedSize
                        self.progress.totalUnitCount = expectedSize
                        downloadProgress?(self, self.progress)
                    }
                }, completed: { (image: UIImage?, imageData: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
                    JSAsyncExecuteOnMainQueue {
                        self.error = error
                        if image != nil && error == nil && finished {
                            sourceItem.image = image
                            /// sourceItem有可能是struct类型, 所以这里需要赋值
                            self.sourceItem = sourceItem
                        }
                        self.isFinished = finished
                        completed?(self, image, imageData, error, cancelled, finished)
                    }
                })
            }
        }
    }
    
    public func cancelRequest(for imageView: UIImageView) {
        self.webImageMediator?.cancelImageRequest(for: imageView)
    }
    
}
