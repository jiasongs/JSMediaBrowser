//
//  BasisCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

open class BasisCell: UICollectionViewCell, CellProtocol {
    
    open lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.isHidden = true
        view.onPressAction = { [weak self] (sender: UIButton) in
            if let strongSelf = self {
                strongSelf.onEmptyPressAction?(strongSelf)
            }
        }
        return view
    }()
    
    open lazy var pieProgressView: PieProgressView = {
        let view = PieProgressView()
        view.tintColor = .white
        view.minimumProgress = 0.05
        return view
    }()
    
    open var onEmptyPressAction: ((UICollectionViewCell) -> Void)?
    open var willDisplayEmptyView: ((UICollectionViewCell, EmptyView, NSError) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        self.contentView.addSubview(self.emptyView)
        self.contentView.addSubview(self.pieProgressView)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        self.contentView.bringSubviewToFront(self.pieProgressView)
        self.emptyView.isHidden = true
        self.pieProgressView.isHidden = false
        self.pieProgressView.progress = 0.0
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.emptyView.frame = self.bounds
        let width = min(self.bounds.width * 0.12, 86)
        let progressSize = CGSize(width: width, height: width)
        let progressPoint = CGPoint(x: (self.bounds.width - progressSize.width) / 2, y: (self.bounds.height - progressSize.height) / 2)
        self.pieProgressView.frame = CGRect(origin: progressPoint, size: progressSize)
    }
    
    public func setProgress(_ progress: Progress) {
        self.pieProgressView.setProgress(Float(progress.fractionCompleted))
    }
    
    public func setError(_ error: NSError?, cancelled: Bool, finished: Bool) {
        if cancelled {
            self.pieProgressView.isHidden = false
        } else {
            if let error = error {
                self.willDisplayEmptyView?(self, self.emptyView, error)
                self.emptyView.isHidden = false
            } else {
                self.emptyView.isHidden = true
            }
            self.pieProgressView.isHidden = true
        }
    }
    
}
