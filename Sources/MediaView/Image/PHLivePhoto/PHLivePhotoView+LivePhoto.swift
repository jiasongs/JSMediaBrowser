//
//  PHLivePhotoView+LivePhoto.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/30.
//

import UIKit
import PhotosUI

extension PHLivePhoto: LivePhoto {}

extension PHLivePhotoView: LivePhotoView {
    
    public var isPlaying: Bool {
        return self.delegator?.isPlaying ?? false
    }
    
    public func startPlayback() {
        self.delegate = self.delegator
        
        self.startPlayback(with: .full)
    }
    
    private var delegator: PHLivePhotoViewDelegator? {
        var delegator = objc_getAssociatedObject(self, &AssociatedKeys.delegator) as? PHLivePhotoViewDelegator
        if delegator == nil {
            delegator = PHLivePhotoViewDelegator()
            objc_setAssociatedObject(self, &AssociatedKeys.delegator, delegator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return delegator
    }
    
}

private final class PHLivePhotoViewDelegator: NSObject, PHLivePhotoViewDelegate {
    
    var isPlaying: Bool = false
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.isPlaying = true
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.isPlaying = false
    }
    
}

private struct AssociatedKeys {
    static var delegator: UInt8 = 0
}
