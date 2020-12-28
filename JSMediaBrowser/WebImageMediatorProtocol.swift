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

@objc(MediaBrowserWebImageMediatorProtocol)
public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    func setImage(forView view: UIView?, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?)
    
    func cancelImageRequest(forView view: UIView?)
    
}
