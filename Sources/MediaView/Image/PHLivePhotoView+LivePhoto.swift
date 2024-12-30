//
//  PHLivePhotoView+LivePhoto.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/30.
//

import UIKit
import PhotosUI

// extension PHLivePhoto: LivePhoto {}

extension PHLivePhotoView: LivePhotoView {
    
    public var livePhoto: LivePhoto? {
        get {
            return nil
        }
        set {
            
        }
    }

    public var isPlaying: Bool {
        return false
    }
    
    public func startPlayback() {
        self.delegate = self
        
        self.startPlayback(with: .full)
    }
    
}

extension PHLivePhotoView: @retroactive PHLivePhotoViewDelegate {
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
     
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {

    }
    
}
