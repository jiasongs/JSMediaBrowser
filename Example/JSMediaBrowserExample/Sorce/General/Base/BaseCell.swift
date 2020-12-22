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
        loaderEntity.willBecomeDownloadBlock = { [weak self] (loader) in
            self?.loaderEntityWillBecomeDownload(loader)
        }
        loaderEntity.downloadProgressBlock = { [weak self] (loader, progress: Progress?) -> Void in
            self?.loaderEntity(loader, didReceive: progress)
        }
        loaderEntity.completedBlock = { [weak self] (loader, data: Any?, error: Error?, finished: Bool) -> Void in
            self?.loaderEntity(loader, didCompletion: data, error: error, finished: finished)
        }
    }
    
    public func loaderEntityWillBecomeDownload(_ loaderEntity: LoaderProtocol) {
        self.pieProgressView?.isHidden = false
    }
    
    public func loaderEntity(_ loaderEntity: LoaderProtocol, didReceive progress: Progress?) {
        if let progress = progress {
            self.pieProgressView?.setProgress(Float(progress.completedUnitCount / progress.totalUnitCount), animated: true)
        }
    }
    
    public func loaderEntity(_ loaderEntity: LoaderProtocol, didCompletion data: Any?, error: Error?, finished: Bool) {
        self.pieProgressView?.isHidden = true
    }
    
}
