//
//  VideoLoaderEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import Foundation

public class VideoLoaderEntity: VideoLoaderProtocol {
    
    public var sourceItem: SourceProtocol?
    public var progress: Progress = Progress()
    public var error: NSError?
    public var isFinished: Bool = false
    
}
