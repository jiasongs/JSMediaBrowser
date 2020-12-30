//
//  BaseLoaderEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserLoaderEntity)
open class BaseLoaderEntity: NSObject, LoaderProtocol {
    
    public var sourceItem: SourceProtocol?
    public var state: LoaderState = .none
    public var progress: Progress?
    public var error: NSError?
    
    public override init() {
        super.init()
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        self.progress = Progress(totalUnitCount: -1)
    }
    
    @objc public func request(forView view: UIView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) {
        self.state = .start
        self.error = nil
        self.progress?.completedUnitCount = 0
        self.progress?.totalUnitCount = -1
    }
    
    @objc public func cancelRequest(forView view: UIView) {
        
    }
    
}
