//
//  ImageLoaderEntity.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/13.
//

import UIKit

@objc(MediaBrowserImageLoaderEntity)
class ImageLoaderEntity: BaseLoaderEntity, ImageLoaderProtocol {
    
    var webImageMediator: WebImageMediatorProtocol?
    var token: Any?
    
    override func request() {
        super.request()
        if self.state != .none {
            return
        }
        guard let sourceItem = self.sourceItem as? ImageEntity else { return }
        self.state = .start
        if let willBecomeDownloadBlock = self.willBecomeDownloadBlock {
            willBecomeDownloadBlock(self)
        }
        self.token = self.webImageMediator?.loadImage(url: sourceItem.imageUrl, progress: { (receivedSize: Int64, expectedSize: Int64) in
            DispatchQueue.main.async {
                self.state = .loading
                self.progress?.completedUnitCount = Int64(receivedSize)
                self.progress?.totalUnitCount = Int64(expectedSize)
                if let downloadProgress = self.downloadProgressBlock {
                    downloadProgress(self, self.progress)
                }
            }
        }, completed: { (data: Any?, error: Error?, finished: Bool) in
            DispatchQueue.main.async {
                self.state = .end
                if let image = data as? UIImage {
                    sourceItem.image = image
                }
                if let completedBlock = self.completedBlock {
                    completedBlock(self, data, error, finished)
                }
            }
        })
    }
    
    deinit {
        if let token = self.token {
            self.webImageMediator?.cancelLoadImage(with: token)
        }
    }
    
}
