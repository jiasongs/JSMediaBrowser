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
    private(set) var collectionView: PagingCollectionView!
    private(set) var collectionViewLayout: PagingLayout!
    public var currentMediaIndex: Int = 0 {
        didSet {
            self.setCurrentMediaIndex(currentMediaIndex, animated: false)
        }
    }
    
    private var isChangingCollectionViewBounds: Bool!
    private var previousIndexWhenScrolling: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialized(frame: frame);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialized(frame: CGRect.zero)
    }
    
    func didInitialized(frame: CGRect) -> Void {
        self.collectionViewLayout = PagingLayout.init()
        self.collectionView = PagingCollectionView.init(frame: frame, collectionViewLayout: self.collectionViewLayout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
}

extension MediaBrowserView {
    
    @objc open func setCurrentMediaIndex(_ index: Int, animated: Bool) -> Void {
        currentMediaIndex = index;
        self.collectionView .reloadData()
        if index < self.collectionView.numberOfItems(inSection: 0) {
            self.collectionView.scrollToItem(at: NSIndexPath.init(item: self.currentMediaIndex, section: 0) as IndexPath, at: .centeredHorizontally, animated: animated)
            self.collectionView.layoutIfNeeded()
        }
    }
    
    @objc open func reloadData() -> Void {
        self.collectionView.reloadData()
    }
    
    @objc open func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    @objc open func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
}

extension MediaBrowserView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfMediaItemsInBrowserView(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.dataSource?.mediaBrowserView(self, cellForItemAt: indexPath) ?? UICollectionViewCell.init();
    }
    
}

extension MediaBrowserView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.delegate != nil && self.delegate!.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:willDisplay:forItemAt:))) {
            self.delegate?.mediaBrowserView?(self, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.delegate != nil && self.delegate!.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:didEndDisplaying:forItemAt:))) {
            self.delegate?.mediaBrowserView?(self, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != self.collectionView {
            return
        }
        if self.delegate != nil && self.delegate!.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:didScrollTo:))) {
            self.delegate?.mediaBrowserView?(self, didScrollTo: self.currentMediaIndex)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != self.collectionView {
            return
        }
        if self.isChangingCollectionViewBounds {
            return
        }
        
        let betweenOrEqual =  { (minimumValue: CGFloat, value: CGFloat, maximumValue: CGFloat) -> Bool in
            return minimumValue <= value && value <= maximumValue;
        }
        
        let pageWidth: CGFloat = self.collectionView(self.collectionView, layout: self.collectionViewLayout, sizeForItemAt: IndexPath.init(item: 0, section: 0)).width
        let pageHorizontalMargin: CGFloat = self.collectionViewLayout.pageSpacing;
        let contentOffsetX: CGFloat = self.collectionView.contentOffset.x
        var index: CGFloat = contentOffsetX / (pageWidth + pageHorizontalMargin)
        
        let isFirstDidScroll: Bool = self.previousIndexWhenScrolling == 0;
        
        // fastToRight example : self.previousIndexWhenScrolling 1.49, index = 2.0
        let fastToRight: Bool = (floor(index) - floor(self.previousIndexWhenScrolling) >= 1.0) && (floor(index) - self.previousIndexWhenScrolling > 0.5);
        let turnPageToRight: Bool = fastToRight || betweenOrEqual(self.previousIndexWhenScrolling, floor(index) + 0.5, index);
        
        // fastToLeft example : self.previousIndexWhenScrolling 2.51, index = 1.99
        let fastToLeft: Bool = (floor(self.previousIndexWhenScrolling) - floor(index) >= 1.0) && (self.previousIndexWhenScrolling - ceil(index) > 0.5);
        let turnPageToLeft: Bool = fastToLeft || betweenOrEqual(index, floor(index) + 0.5, self.previousIndexWhenScrolling);
        
        if !isFirstDidScroll && (turnPageToRight || turnPageToLeft) {
            index = round(index);
            if 0 <= index && Int(index) < self.collectionView.numberOfItems(inSection: 0) {
                
                // 不调用 setter，避免又走一次 scrollToItem
                currentMediaIndex = Int(index);
                
                if self.delegate != nil && self.delegate!.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:willScrollHalfTo:))) {
                    self.delegate?.mediaBrowserView?(self, willScrollHalfTo: Int(index))
                }
            }
        }
        self.previousIndexWhenScrolling = index;
    }
    
}

extension MediaBrowserView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let isCollectionViewSizeChanged = !self.collectionView.bounds.size.equalTo(self.bounds.size)
        if isCollectionViewSizeChanged {
            self.isChangingCollectionViewBounds = true;
            self.collectionViewLayout.invalidateLayout();
            self.collectionView.frame = self.bounds;
            self.collectionView.scrollToItem(at: NSIndexPath.init(item: self.currentMediaIndex, section: 0) as IndexPath, at: .centeredHorizontally, animated: false)
            self.isChangingCollectionViewBounds = false;
        }
    }
    
}
