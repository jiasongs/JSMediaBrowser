//
//  ZoomAssetView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2025/1/2.
//

import UIKit

public protocol ZoomAsset: Equatable {
    
    var size: CGSize { get }
    
}

public protocol ZoomAssetView: UIView {
    
    associatedtype ZoomAssetType: ZoomAsset
    
    var asset: ZoomAssetType? { get set }
    
    var isPlaying: Bool { get }
    
    func startPlaying()
    func stopPlaying()
    
}

internal extension ZoomAssetView {
    
    func isEqual(lhs: (any ZoomAsset)?, rhs: (any ZoomAsset)?) -> Bool {
        let lhs = lhs as? ZoomAssetType
        let rhs = rhs as? ZoomAssetType
        return lhs == rhs
    }
    
    func setAsset(_ asset: (any ZoomAsset)?) {
        self.asset = asset as? ZoomAssetType
    }
    
}
