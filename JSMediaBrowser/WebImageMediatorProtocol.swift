//
//  WebImageMediatorProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public typealias WebImageMediatorSetImageBlock = (_ image: UIImage?, _ imageData: Data?) -> Void
public typealias WebImageMediatorDownloadProgress = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void
public typealias WebImageMediatorCompleted = (_ image: UIImage?, _ imageData: Data?, _ error: Error?, _ finished: Bool) -> Void

@objc public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    func setImage(for view: UIView?, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?)
    
    func cancelImageRequest(for view: UIView?)
    
}
