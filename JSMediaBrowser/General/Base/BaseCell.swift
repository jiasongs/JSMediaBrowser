//
//  BaseCell.swift
//  JSMediaBrowser
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
        pieProgressView = PieProgressView()
        pieProgressView?.tintColor = .white
        contentView.addSubview(self.pieProgressView!)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        if let pieProgressView = self.pieProgressView {
            contentView.bringSubviewToFront(pieProgressView)
        }
        pieProgressView?.isHidden = false
        pieProgressView?.progress = 0.0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let size = CGSize(width: self.bounds.width * 0.15, height: self.bounds.width * 0.15)
        let point = CGPoint(x: (self.bounds.width - size.width) / 2, y: (self.bounds.height - size.height) / 2)
        self.pieProgressView?.frame = CGRect(origin: point, size: size)
    }
    
    public func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        self.pieProgressView?.isHidden = false
        loaderEntity.request(for: self.contentView) { [weak self](loader: LoaderProtocol, object: Any?, data: Data?) in
            self?.loaderEntity(loader, setData: object, data: data)
        } downloadProgress: { [weak self](loader: LoaderProtocol, progress: Progress?) in
            self?.loaderEntity(loader, didReceive: progress)
        } completed: { [weak self](loader: LoaderProtocol, object: Any?, data: Data?, error: Error?, finished: Bool) in
            self?.loaderEntity(loader, didCompleted: object, data: data, error: error, finished: finished)
        }
    }
    
    public func loaderEntity(_ loaderEntity: LoaderProtocol, setData object: Any?, data: Data?) {
        
    }
    
    public func loaderEntity(_ loaderEntity: LoaderProtocol, didReceive progress: Progress?) {
        if let pieProgressView = self.pieProgressView, pieProgressView.isHidden {
            pieProgressView.isHidden = true
        }
        if let progress = progress {
            self.pieProgressView?.setProgress(Float(progress.fractionCompleted), animated: true)
        }
    }
    
    public func loaderEntity(_ loaderEntity: LoaderProtocol, didCompleted object: Any?, data: Data?, error: Error?, finished: Bool) {
        if error != nil {
            /// 显示错误图
            return
        }
        if object != nil {
            self.pieProgressView?.isHidden = true
        }
    }
    
    deinit {
        
    }
    
}
