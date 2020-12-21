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
        if let willLoadBlock = self.willLoadBlock {
            willLoadBlock()
        }
        self.state = .start
        self.token = self.webImageMediator?.loadImage(url: sourceItem.imageUrl, progress: { (receivedSize: Int, expectedSize: Int) in
            self.state = .loading
            self.progress?.completedUnitCount = Int64(receivedSize)
            self.progress?.totalUnitCount = Int64(expectedSize)
            if let downloadProgress = self.downloadProgressBlock {
                downloadProgress(receivedSize, expectedSize)
            }
        }, completed: { (data: Any?, error: Error?, finished: Bool) in
            self.state = .end
            if let image = data as? UIImage {
                sourceItem.image = image
            }
            if let completedBlock = self.completedBlock {
                completedBlock(data, error, finished)
            }
        })
    }
    
    deinit {
        if let token = self.token {
            self.webImageMediator?.cancelLoadImage(with: token)
        }
    }
    
}
