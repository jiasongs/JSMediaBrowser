//
//  CellProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public protocol CellProtocol {
    
    func setProgress(_ progress: Progress)
    func setError(_ error: NSError?, cancelled: Bool, finished: Bool)
    
}

extension CellProtocol {
    
    func setProgress(_ progress: Progress) {}
    func setError(_ error: NSError?, cancelled: Bool, finished: Bool) {}
    
}
