//
//  MediaBrowserView.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public class MediaBrowserView: UIView {
    
    public weak var dataSource: MediaBrowserViewDataSource?
    public weak var delegate: MediaBrowserViewDelegate?
    
    private(set) var collectionView: PagingCollectionView?
    private(set) var collectionViewLayout: PagingLayout?
    
    public var currentMediaIndex: Int = 0 {
        didSet {
            if isNeededScrollToItem {
                self.setCurrentMedia(index: self.currentMediaIndex, animated: false)
            }
        }
    }
    
    private var isChangingCollectionViewBounds: Bool = false
    private var previousIndexWhenScrolling: CGFloat = 0
    private var isNeededScrollToItem: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    func didInitialize(frame: CGRect) -> Void {
        self.collectionViewLayout = PagingLayout.init()
        self.collectionView = PagingCollectionView.init(frame: frame, collectionViewLayout: self.collectionViewLayout!)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.addSubview(self.collectionView!)
    }
    
}

extension MediaBrowserView {
    
    @objc open func setCurrentMedia(index: Int, animated: Bool) -> Void {
        self.isNeededScrollToItem = false
        self.currentMediaIndex = index
        self.isNeededScrollToItem = true
        self.collectionView?.reloadData()
        guard let numberOfItems = self.collectionView?.numberOfItems(inSection: 0) else { return }
        if index < numberOfItems {
            self.collectionView?.scrollToItem(at: IndexPath.init(item: self.currentMediaIndex, section: 0), at: .centeredHorizontally, animated: animated)
            self.collectionView?.layoutIfNeeded()
        }
    }
    
    @objc open func reloadData() -> Void {
        self.collectionView?.reloadData()
    }
    
    @objc open func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        self.collectionView?.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    @objc open func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return self.collectionView?.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) ?? UICollectionViewCell.init()
    }
    
}

extension MediaBrowserView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfMediaItemsInBrowserView(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.dataSource?.mediaBrowserView(self, cellForItemAt: indexPath) ?? UICollectionViewCell.init()
    }
    
}

extension MediaBrowserView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:willDisplay:forItemAt:))) {
            delegate.mediaBrowserView?(self, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:didEndDisplaying:forItemAt:))) {
            delegate.mediaBrowserView?(self, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != self.collectionView {
            return
        }
        if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:didScrollTo:))) {
            delegate.mediaBrowserView?(self, didScrollTo: self.currentMediaIndex)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != self.collectionView {
            return
        }
        if self.isChangingCollectionViewBounds {
            return
        }
        guard let collectionView = self.collectionView else { return }
        guard let collectionViewLayout = self.collectionViewLayout else { return }
        let betweenOrEqual =  { (minimumValue: CGFloat, value: CGFloat, maximumValue: CGFloat) -> Bool in
            return minimumValue <= value && value <= maximumValue
        }
        let pageWidth: CGFloat = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath.init(item: 0, section: 0)).width
        let pageHorizontalMargin: CGFloat = collectionViewLayout.pageSpacing
        let contentOffsetX: CGFloat = collectionView.contentOffset.x
        var index: CGFloat = contentOffsetX / (pageWidth + pageHorizontalMargin)
        let isFirstDidScroll: Bool = self.previousIndexWhenScrolling == 0
        let fastToRight: Bool = (floor(index) - floor(self.previousIndexWhenScrolling) >= 1.0) && (floor(index) - self.previousIndexWhenScrolling > 0.5)
        let turnPageToRight: Bool = fastToRight || betweenOrEqual(self.previousIndexWhenScrolling, floor(index) + 0.5, index)
        let fastToLeft: Bool = (floor(self.previousIndexWhenScrolling) - floor(index) >= 1.0) && (self.previousIndexWhenScrolling - ceil(index) > 0.5)
        let turnPageToLeft: Bool = fastToLeft || betweenOrEqual(index, floor(index) + 0.5, self.previousIndexWhenScrolling)
        
        if !isFirstDidScroll && (turnPageToRight || turnPageToLeft) {
            index = round(index)
            if 0 <= index && Int(index) < collectionView.numberOfItems(inSection: 0) {
                self.isNeededScrollToItem = false
                self.currentMediaIndex = Int(index)
                self.isNeededScrollToItem = true
                if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:willScrollHalfTo:))) {
                    self.delegate?.mediaBrowserView?(self, willScrollHalfTo: Int(index))
                }
            }
        }
        self.previousIndexWhenScrolling = index
    }
    
}

extension MediaBrowserView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let collectionView = self.collectionView  else { return }
        let isCollectionViewSizeChanged = !collectionView.bounds.size.equalTo(self.bounds.size)
        if isCollectionViewSizeChanged {
            self.isChangingCollectionViewBounds = true
            self.collectionViewLayout?.invalidateLayout()
            self.collectionView?.frame = self.bounds
            self.collectionView?.scrollToItem(at: IndexPath.init(item: self.currentMediaIndex, section: 0), at: .centeredHorizontally, animated: false)
            self.isChangingCollectionViewBounds = false
        }
    }
    
}
