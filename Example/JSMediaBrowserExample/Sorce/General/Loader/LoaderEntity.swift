//
//  MediaBrowserLoader.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserLoaderEntity)
open class LoaderEntity: NSObject, MediaBrowserViewLoaderProtocol {

    public var sourceItem: MediaBrowserViewSourceProtocol?
    
}
