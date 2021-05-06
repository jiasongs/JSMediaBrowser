//
//  BasisLoaderEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(JSMediaBrowserBasisLoaderEntity)
open class BasisLoaderEntity: NSObject, LoaderProtocol {
    
    public var sourceItem: SourceProtocol?
    public var progress: Progress?
    public var error: NSError?
    public var isFinished: Bool = false
    
    public override init() {
        super.init()
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        self.progress = Progress(totalUnitCount: -1)
    }
    
}
