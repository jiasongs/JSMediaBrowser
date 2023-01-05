//
//  VideoProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/5.
//

import UIKit
import AVKit

public protocol VideoSourceProtocol: SourceProtocol {
    
    var videoUrl: URL? { get set }
    var videoAsset: AVAsset? { get set }
    
}
