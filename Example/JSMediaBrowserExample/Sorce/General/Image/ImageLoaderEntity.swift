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
    
    override func request(prepare: PrepareBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) -> Void {
        super.request(prepare: prepare, downloadProgress: downloadProgress, completed: completed)
//        if self.state != .none {
//            return
//        }
//        guard let sourceItem = self.sourceItem as? ImageEntity else { return }
//        self.state = .start
//        if let prepareBlock = self.prepareBlock {
//            prepareBlock(self)
//        }
//        self.webImageMediator?.setImage(for: self, url: <#T##URL?#>, thumbImage: <#T##UIImage?#>, setImageBlock: <#T##WebImageMediatorSetImageBlock?##WebImageMediatorSetImageBlock?##(UIImage?, Data?) -> Void#>, progress: <#T##WebImageMediatorDownloadProgress?##WebImageMediatorDownloadProgress?##(Int64, Int64) -> Void#>, completed: <#T##WebImageMediatorCompleted?##WebImageMediatorCompleted?##(UIImage?, Data?, Error?, Bool) -> Void#>)
//        self.token = self.webImageMediator?.loadImage(url: sourceItem.imageUrl, progress: { (receivedSize: Int64, expectedSize: Int64) in
//            DispatchQueue.main.async {
//                self.state = .loading
//                self.progress?.completedUnitCount = Int64(receivedSize)
//                self.progress?.totalUnitCount = Int64(expectedSize)
//                if let downloadProgress = self.downloadProgressBlock {
//                    downloadProgress(self, self.progress)
//                }
//            }
//        }, completed: { (data: Any?, error: Error?, finished: Bool) in
//            DispatchQueue.main.async {
//                self.state = .end
//                if let image = data as? UIImage {
//                    sourceItem.image = image
//                }
//                if let completedBlock = self.completedBlock {
//                    completedBlock(self, data, error, finished)
//                }
//            }
//        })
    }
    
}
