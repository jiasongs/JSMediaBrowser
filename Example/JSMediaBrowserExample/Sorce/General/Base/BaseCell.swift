//
//  BaseCell.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserBaseCell)
open class BaseCell: UICollectionViewCell, CellProtocol {
    
    public var pieProgressView: PieProgressView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        self.pieProgressView = PieProgressView()
        self.pieProgressView?.isHidden = true
        self.contentView.addSubview(self.pieProgressView!)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let size = CGSize(width: self.bounds.width * 0.15, height: self.bounds.width * 0.15)
        let point = CGPoint(x: (self.bounds.width - size.width) / 2, y: (self.bounds.height - size.height) / 2)
        self.pieProgressView?.frame = CGRect(origin: point, size: size)
    }
    
    public func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
    }
    
}
