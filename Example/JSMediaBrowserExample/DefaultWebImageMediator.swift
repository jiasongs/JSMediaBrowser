//
//  DefaultWebImageMediator.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/13.
//

import UIKit
import SDWebImage

@objc(MediaBrowserViewDefaultWebImageMediator)
class DefaultWebImageMediator: NSObject, WebImageMediatorProtocol {
       
    func loadImage(url: URL, progress: (Int, Int) -> Void, completed: (UIImage, Error, Bool) -> Void) -> Any? {
        return nil
    }
    
    func cancelLoadImage(any: Any) -> Bool {
        return false
    }
    
    func cancelAll() -> Bool {
        return false
    }
    
}
