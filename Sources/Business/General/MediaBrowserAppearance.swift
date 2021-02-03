//
//  MediaBrowserAppearance.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit
import PhotosUI

#if BUSINESS_IMAGE
public typealias BuildImageViewInZoomViewBlock = (MediaBrowserViewController, ZoomImageView) -> UIImageView
public typealias BuildLivePhotoViewInZoomViewBlock = (MediaBrowserViewController, ZoomImageView) -> PHLivePhotoView
public typealias BuildWebImageMediatorBlock = (MediaBrowserViewController, SourceProtocol) -> WebImageMediatorProtocol
#endif
public typealias BuildToolViewsBlock = (MediaBrowserViewController) -> Array<UIView & ToolViewProtocol>
public typealias BuildCellBlock = (MediaBrowserViewController, Int) -> UICollectionViewCell?
public typealias ConfigureCellBlock = (MediaBrowserViewController, UICollectionViewCell, Int) -> Void
public typealias DisplayEmptyViewBlock = (MediaBrowserViewController, UICollectionViewCell, EmptyView, NSError) -> Void
public typealias LongPressBlock = (MediaBrowserViewController) -> Void

public typealias Identifier = String
public typealias CellClassSting = String

@objc open class MediaBrowserAppearance: NSObject {
    
    @objc public static let appearance = MediaBrowserAppearance()
    
    #if BUSINESS_IMAGE
    @objc public var addImageViewInZoomViewBlock: BuildImageViewInZoomViewBlock?
    @objc public var addLivePhotoViewInZoomViewBlock: BuildLivePhotoViewInZoomViewBlock?
    @objc public var addWebImageMediatorBlock: BuildWebImageMediatorBlock?
    #endif
    @objc public var addToolViewsBlock: BuildToolViewsBlock?
    @objc public var cellForItemAtIndexBlock: BuildCellBlock?
    @objc public var configureCellBlock: ConfigureCellBlock?
    @objc public var willDisplayEmptyViewBlock: DisplayEmptyViewBlock?
    @objc public var onLongPressBlock: LongPressBlock?
    
    @objc lazy private(set) public var reuseCellIdentifiers: Dictionary<Identifier, CellClassSting> = Dictionary()
    
    @objc public func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        self.reuseCellIdentifiers[identifier] = NSStringFromClass(cellClass)
    }
    
    fileprivate override init() {
        super.init()
    }
    
}
