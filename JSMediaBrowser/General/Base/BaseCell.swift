//
//  BaseCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserBaseCell)
open class BaseCell: UICollectionViewCell, CellProtocol {
    
    @objc public var emptyView: EmptyView?
    @objc public var pieProgressView: PieProgressView?
    @objc public var onEmptyPressAction: ((UICollectionViewCell) -> Void)?
    @objc public var willDisplayEmptyViewBlock: ((UICollectionViewCell, EmptyView, NSError?) -> Void)?
    @objc public var didLoaderCompleted: ((UICollectionViewCell, Any?, NSError?) -> Void)?
    
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
        emptyView?.frame = self.bounds
        let progressSize = CGSize(width: min(self.bounds.width * 0.12, 120), height: min(self.bounds.width * 0.12, 120))
        let progressPoint = CGPoint(x: (self.bounds.width - progressSize.width) / 2, y: (self.bounds.height - progressSize.height) / 2)
        self.pieProgressView?.frame = CGRect(origin: progressPoint, size: progressSize)
    }
    
    public func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        loaderEntity.cancelRequest(forView: self.contentView)
        loaderEntity.request(forView: self.contentView) { [weak self](loader: LoaderProtocol, object: Any?, data: Data?) in
            self?.loaderEntity(loader, setData: object, data: data)
        } downloadProgress: { [weak self](loader: LoaderProtocol, progress: Progress?) in
            self?.loaderEntity(loader, didReceive: progress)
        } completed: { [weak self](loader: LoaderProtocol, object: Any?, data: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
            self?.loaderEntity(loader, didCompleted: object, data: data, error: error, cancelled: cancelled, finished: finished)
        }
    }
    
    public func loaderEntity(_ loaderEntity: LoaderProtocol, setData object: Any?, data: Data?) {
        
    }
    
    public func loaderEntity(_ loaderEntity: LoaderProtocol, didReceive progress: Progress?) {
        if let progress = progress {
            self.layoutIfNeeded()
            pieProgressView?.setProgress(Float(progress.fractionCompleted), animated: true)
        }
    }
    
    public func loaderEntity(_ loaderEntity: LoaderProtocol, didCompleted object: Any?, data: Data?, error: NSError?, cancelled: Bool, finished: Bool) {
        if cancelled {
            pieProgressView?.isHidden = false
        } else {
            if error != nil {
                if let block = self.willDisplayEmptyViewBlock, let emptyView = self.emptyView {
                    block(self, emptyView, error)
                }
                emptyView?.isHidden = false
            } else {
                emptyView?.isHidden = true
            }
            pieProgressView?.isHidden = true
        }
        if let block = self.didLoaderCompleted {
            block(self, object, error)
        }
    }
    
}
