//
//  CellProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

@objc(MediaBrowserCellProtocol)
public protocol CellProtocol: NSObjectProtocol {
    
    @objc(updateCell:atIndex:)
    func updateCell(loaderEntity: LoaderProtocol, at index: Int)
    
    @objc(loaderEntity:setDataWithObject:data:)
    func loaderEntity(_ loaderEntity: LoaderProtocol, setData object: Any?, data: Data?)
    
    @objc(loaderEntity:didReceiveWithProgress:)
    func loaderEntity(_ loaderEntity: LoaderProtocol, didReceive progress: Progress?)
    
    @objc(loaderEntity:didCompletedWithObject:data:error:cancelled:finished:)
    func loaderEntity(_ loaderEntity: LoaderProtocol, didCompleted object: Any?, data: Data?, error: NSError?, cancelled: Bool, finished: Bool)
    
}
