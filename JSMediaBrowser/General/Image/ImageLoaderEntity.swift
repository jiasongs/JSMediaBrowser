//
//  ImageLoaderEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/13.
//

import UIKit

@objc(MediaBrowserImageLoaderEntity)
open class ImageLoaderEntity: BaseLoaderEntity, ImageLoaderProtocol {
    
    public var webImageMediator: WebImageMediatorProtocol?
    
    public override func request(for view: UIView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) {
        super.request(for: view, setDataBlock: setDataBlock, downloadProgress: downloadProgress, completed: completed)
        if let sourceItem = self.sourceItem as? ImageEntity {
            self.webImageMediator?.setImage(for: view, url: sourceItem.imageUrl, thumbImage: sourceItem.thumbImage, setImageBlock: { (image: UIImage?, imageData: Data?) in
                if let setDataBlock = setDataBlock {
                    setDataBlock(self, image, imageData)
                }
            }, progress: { (receivedSize: Int64, expectedSize: Int64) in
                self.state = .loading
                if let downloadProgress = downloadProgress {
                    DispatchQueue.main.async {
                        self.progress?.completedUnitCount = receivedSize
                        self.progress?.totalUnitCount = expectedSize
                        downloadProgress(self, self.progress)
                    }
                }
            }, completed: { (image: UIImage?, imageData: Data?, error: Error?, finished: Bool) in
                self.state = .end
                self.error = error
                if image != nil && error == nil && finished {
                    sourceItem.image = image
                }
                if let completed = completed {
                    DispatchQueue.main.async {
                        completed(self, image, imageData, error, finished)
                    }
                }
            })
        }
    }
    
    public override func cancelRequest(for view: UIView) {
        self.webImageMediator?.cancelImageRequest(for: view)
    }
    
}
