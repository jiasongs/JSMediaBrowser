//
//  WebImageMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public typealias WebImageMediatorSetImageBlock = (_ image: UIImage?) -> Void
public typealias WebImageMediatorDownloadProgress = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void
public typealias WebImageMediatorCompleted = (_ result: Result<WebImageResult, WebImageError>) -> Void

public protocol WebImageMediator {
    
    func setImage(for view: UIView,
                  url: URL?,
                  thumbImage: UIImage?,
                  setImageBlock: WebImageMediatorSetImageBlock?,
                  progress: WebImageMediatorDownloadProgress?,
                  completed: WebImageMediatorCompleted?)
    
    func cancelImageRequest(for view: UIView)
    
}

public struct WebImageResult {
    
    public let image: UIImage?
    
    public let data: Data?
    
}

public struct WebImageError: Error {
    
    public let error: NSError
    
    public let cancelled: Bool
    
}
