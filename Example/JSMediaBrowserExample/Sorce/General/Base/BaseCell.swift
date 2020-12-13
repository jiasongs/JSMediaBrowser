//
//  BaseCell.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserBaseCell)
open class BaseCell: UICollectionViewCell, CellProtocol {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        
    }
    
    public func updateCell<T>(loaderEntity: T, at indexPath: IndexPath) {
        
    }
    
    public func updateLoading(receivedSize: Int, expectedSize: Int) {
        
    }
    
}
