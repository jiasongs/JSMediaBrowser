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
    
    func didReceive(with progress: Progress?)
    func didCompleted(with error: NSError?, cancelled: Bool, finished: Bool)
    
}
