//
//  MediaBrowserAppearance.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit
import PhotosUI

public typealias BuildImageViewInZoomViewBlock = (MediaBrowserViewController, ZoomImageView) -> UIImageView
public typealias BuildLivePhotoViewInZoomViewBlock = (MediaBrowserViewController, ZoomImageView) -> PHLivePhotoView
public typealias BuildWebImageMediatorBlock = (MediaBrowserViewController, SourceProtocol) -> WebImageMediatorProtocol
public typealias BuildToolViewsBlock = (MediaBrowserViewController) -> Array<UIView & ToolViewProtocol>

@objc open class MediaBrowserAppearance: NSObject {
    
    @objc public static let appearance = MediaBrowserAppearance()
    
    @objc public var addImageViewInZoomViewBlock: BuildImageViewInZoomViewBlock?
    @objc public var addLivePhotoViewInZoomViewBlock: BuildLivePhotoViewInZoomViewBlock?
    @objc public var addWebImageMediatorBlock: BuildWebImageMediatorBlock?
    @objc public var addToolViewsBlock: BuildToolViewsBlock?
    
    @objc public var progressTintColor: UIColor?
    
}
