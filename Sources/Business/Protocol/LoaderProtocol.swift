//
//  LoaderProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public protocol LoaderProtocol {
    
    var sourceItem: SourceProtocol? { get set }
    var progress: Progress { get set }
    var error: NSError? { get set }
    var isFinished: Bool { get set }
    
}
