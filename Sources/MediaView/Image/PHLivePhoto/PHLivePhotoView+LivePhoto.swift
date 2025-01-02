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
        return self._isPlaying
    }
    
    public func startPlayback() {
        self.startPlayback(with: .full)
    }
    
    private var _isPlaying: Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.isPlaying) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isPlaying, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

private final class PHLivePhotoViewDelegator: NSObject, PHLivePhotoViewDelegate {
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        // self._isPlaying
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        
    }
    
}

private struct AssociatedKeys {
    static var isPlaying: UInt8 = 0
}
