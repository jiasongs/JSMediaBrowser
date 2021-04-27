//
//  WebImageMediatorProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public typealias WebImageMediatorSetImageBlock = (_ image: UIImage?, _ imageData: Data?) -> Void
public typealias WebImageMediatorDownloadProgress = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void
public typealias WebImageMediatorCompleted = (_ image: UIImage?, _ imageData: Data?, _ error: NSError?, _ cancelled: Bool, _ finished: Bool) -> Void

@objc(JSMediaBrowserWebImageMediatorProtocol)
public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    @objc(setImageForImageView:url:thumbImage:setImageBlock:progress:completed:)
    func setImage(for imageView: UIImageView?, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?)
    
    @objc(cancelImageRequestForImageView:)
    func cancelImageRequest(for imageView: UIImageView?)
    
}
