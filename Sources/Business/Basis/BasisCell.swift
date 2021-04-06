//
//  BasisCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(JSMediaBrowserBasisCell)
open class BasisCell: UICollectionViewCell, CellProtocol {
    
    @objc public var emptyView: EmptyView?
    @objc public var pieProgressView: PieProgressView?
    @objc public var onEmptyPressAction: ((UICollectionViewCell) -> Void)?
    @objc public var willDisplayEmptyViewBlock: ((UICollectionViewCell, EmptyView, NSError) -> Void)?
    @objc public var didLoaderCompleted: ((UICollectionViewCell, NSError?) -> Void)?
    @objc public var didInitializeBlock: ((UICollectionViewCell) -> Void)?
    fileprivate var initializeExecuteOnce: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        emptyView = EmptyView()
        emptyView?.isHidden = true
        emptyView?.onPressAction = { [weak self] (sender: UIButton) in
            if let strongSelf = self, let block = strongSelf.onEmptyPressAction {
                block(strongSelf)
            }
        }
        contentView.addSubview(emptyView!)
        
        pieProgressView = PieProgressView()
        pieProgressView?.tintColor = .white
        contentView.addSubview(self.pieProgressView!)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        if let pieProgressView = self.pieProgressView {
            contentView.bringSubviewToFront(pieProgressView)
        }
        emptyView?.isHidden = true
        pieProgressView?.isHidden = false
        pieProgressView?.progress = 0.0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.emptyView?.frame = self.bounds
        let width = min(self.bounds.width * 0.12, 86)
        let progressSize = CGSize(width: width, height: width)
        let progressPoint = CGPoint(x: (self.bounds.width - progressSize.width) / 2, y: (self.bounds.height - progressSize.height) / 2)
        self.pieProgressView?.frame = CGRect(origin: progressPoint, size: progressSize)
    }
    
    public func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        if self.initializeExecuteOnce == 0 {
            self.initializeExecuteOnce += 1
            if let block = self.didInitializeBlock {
                block(self)
            }
        }
    }
    
    public func didReceive(with progress: Progress?) {
        if let progress = progress {
            self.layoutIfNeeded()
            self.pieProgressView?.setProgress(Float(progress.fractionCompleted))
        }
    }
    
    public func didCompleted(with error: NSError?, cancelled: Bool, finished: Bool) {
        if cancelled {
            pieProgressView?.isHidden = false
        } else {
            if error != nil {
                if let block = self.willDisplayEmptyViewBlock, let emptyView = self.emptyView {
                    block(self, emptyView, error!)
                }
                emptyView?.isHidden = false
            } else {
                emptyView?.isHidden = true
            }
            pieProgressView?.isHidden = true
        }
        if let block = self.didLoaderCompleted {
            block(self, error)
        }
    }
    
}
