//
//  BaseCell.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserBaseCell)
open class BaseCell: UICollectionViewCell, CellProtocol {
    
    public var emptyView: UIView? {
        get {
            return UIView.init()
        }
    }
    
    public var loadingView: UIView? {
        get {
            return UIView.init()
        }
    }
    
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
    
    open func updateCell(loaderEntity: LoaderProtocol, at indexPath: IndexPath) -> Void {
        
    }
    
}
