//
//  ImageLoaderEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import JSCoreKit

@objc(MediaBrowserImageLoaderEntity)
open class ImageLoaderEntity: BaseLoaderEntity, ImageLoaderProtocol {
    
    @objc public var webImageMediator: WebImageMediatorProtocol?
    
    @objc public override func request(forView view: UIView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) {
        super.request(forView: view, setDataBlock: setDataBlock, downloadProgress: downloadProgress, completed: completed)
        if let sourceItem = self.sourceItem as? ImageSourceProtocol {
            let url: URL? = sourceItem.imageUrl != nil ? sourceItem.imageUrl : sourceItem.originalImageUrl
            self.webImageMediator?.setImage(forView: view, url: url, thumbImage: sourceItem.thumbImage, setImageBlock: { (image: UIImage?, imageData: Data?) in
                if let setDataBlock = setDataBlock {
                    setDataBlock(self, image, imageData)
                }
            }, progress: { (receivedSize: Int64, expectedSize: Int64) in
                self.state = .loading
                if let downloadProgress = downloadProgress {
                    JSAsyncExecuteOnMainQueue {
                        self.progress?.completedUnitCount = receivedSize
                        self.progress?.totalUnitCount = expectedSize
                        downloadProgress(self, self.progress)
                    }
                }
            }, completed: { (image: UIImage?, imageData: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
                self.state = .end
                self.error = error
                if image != nil && error == nil && finished {
                    sourceItem.image = image
                }
                if let completed = completed {
                    JSAsyncExecuteOnMainQueue {
                        completed(self, image, imageData, error, cancelled, finished)
                    }
                }
            })
        }
    }
    
    public override func cancelRequest(forView view: UIView) {
        self.webImageMediator?.cancelImageRequest(forView: view)
    }
    
}
