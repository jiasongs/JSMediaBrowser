//
//  CellProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

@objc public protocol CellProtocol: NSObjectProtocol {
    
    func updateCell(loaderEntity: LoaderProtocol, at index: Int)
    
    func loaderEntity(_ loaderEntity: LoaderProtocol, setData object: Any?, data: Data?)
    func loaderEntity(_ loaderEntity: LoaderProtocol, didReceive progress: Progress?)
    func loaderEntity(_ loaderEntity: LoaderProtocol, didCompleted object: Any?, data: Data?, error: Error?, finished: Bool)
    
}
