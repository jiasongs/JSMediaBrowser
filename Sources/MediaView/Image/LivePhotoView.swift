//
//  LivePhotoView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/30.
//

import UIKit

public protocol LivePhoto: Equatable {
    
    var size: CGSize { get }
    
}

public protocol LivePhotoView: UIView {
    
    associatedtype LivePhotoType: LivePhoto
    
    var livePhoto: LivePhotoType? { get set }
    
    var isPlaying: Bool { get }
    
    func startPlayback()
    func stopPlayback()
    
}

internal extension LivePhotoView {
    
    func isEqual(lhs: (any LivePhoto)?, rhs: (any LivePhoto)?) -> Bool {
        let lhs = lhs as? LivePhotoType
        let rhs = rhs as? LivePhotoType
        return lhs == rhs
    }
    
    func setLivePhoto(_ livePhoto: (any LivePhoto)?) {
        self.livePhoto = livePhoto as? LivePhotoType
    }
    
}
