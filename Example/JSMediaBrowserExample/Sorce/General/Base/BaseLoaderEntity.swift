//
//  BaseLoaderEntity.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserLoaderEntity)
open class BaseLoaderEntity: NSObject, LoaderProtocol {
    
    public var sourceItem: SourceProtocol?
    public var state: LoaderState = .none
    public var progress: Progress?
    public var error: Error?
    public var prepareBlock: PrepareBlock?
    public var downloadProgressBlock: DownloadProgressBlock?
    public var completedBlock: CompletedBlock?
    
    public override init() {
        super.init()
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        self.progress = Progress.current()
    }
    
    public func request(prepare: PrepareBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) -> Void {
        self.prepareBlock = prepare
        self.downloadProgressBlock = downloadProgress
        self.completedBlock = completed
    }
    
}
