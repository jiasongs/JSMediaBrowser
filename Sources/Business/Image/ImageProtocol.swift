//
//  ImageProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/5.
//

import UIKit

public typealias SetDataBlock = (_ loader: LoaderProtocol, _ object: Any?, _ data: Data?) -> Void
public typealias DownloadProgressBlock = (_ loader: LoaderProtocol, _ progress: Progress) -> Void
public typealias CompletedBlock = (_ loader: LoaderProtocol, _ object: Any?, _ data: Data?, _ error: NSError?, _ cancelled: Bool, _ finished: Bool) -> Void

public protocol ImageSourceProtocol: SourceProtocol {
    
    var image: UIImage? { get set }
    var imageUrl: URL? { get set }
    
}

public protocol ImageLoaderProtocol: LoaderProtocol {
    
    var webImageMediator: WebImageMediatorProtocol? { get set }
    
    func request(for imageView: UIImageView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) -> Void
    func cancelRequest(for imageView: UIImageView)
    
}
