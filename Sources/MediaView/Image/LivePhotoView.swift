//
//  LivePhotoView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2024/12/30.
//

import UIKit
import PhotosUI

public struct LivePhoto: Equatable {
    
    var size: CGSize {
        return .zero
    }
    
}

public protocol LivePhotoView: UIView {
    
    var livePhoto: LivePhoto? { get set }
    
    var isPlaying: Bool { get }
    
    func startPlayback()
    func stopPlayback()
    
}
