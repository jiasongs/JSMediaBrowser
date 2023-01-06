//
//  ImageProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/5.
//

import UIKit

public protocol ImageDataItemProtocol: DataItemProtocol {
    
    var image: UIImage? { get set }
    var imageUrl: URL? { get set }
    
}
