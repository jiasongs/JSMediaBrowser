//
//  MediaBrowserView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import JSCoreKit

public class MediaBrowserView: UIView {
    
    public var dataSource: MediaBrowserViewModifier? {
        didSet {
            self.collectionView.dataSource = self
        }
    }
    
    public var plugin: MediaBrowserViewPlugin? {
        didSet {
            self.collectionView.delegate = self
        }
    }
    
    private(set) public lazy var collectionView: PagingCollectionView = {
        return PagingCollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout)
    }()
    
    private(set) public lazy var collectionViewLayout: PagingLayout  = {
        return PagingLayout()
    }()
    
    public var dimmingView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let dimmingView = self.dimmingView {
                self.insertSubview(dimmingView, at: 0)
            }
        }
    }
    
    public lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTapGesture))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    
    public lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTapGesture))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    
    public lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture))
        gesture.minimumPressDuration = 1
        return gesture
    }()
    
    public lazy var dismissingGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismissingGesture))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    public var currentPage: Int = 0 {
        didSet {
            guard self.isNeededScrollToItem else {
                return
            }
            self.scrollToPage(at: self.currentPage, animated: false)
        }
    }
    
    public var totalUnitPage: Int {
        return self.collectionView(self.collectionView, numberOfItemsInSection: 0)
    }
    
    fileprivate var isChangingCollectionViewBounds: Bool = false
    fileprivate var previousPageOffsetRatio: CGFloat = 0.0
    fileprivate var isNeededScrollToItem: Bool = true
    fileprivate var registeredCellIdentifiers: NSMutableSet = NSMutableSet();
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    public func didInitialize(frame: CGRect) {
        self.dimmingView = UIView()
        self.dimmingView?.backgroundColor = .black
        
        self.addSubview(self.collectionView)
        
        self.addGestureRecognizer(self.singleTapGesture)
        self.addGestureRecognizer(self.doubleTapGesture)
        self.addGestureRecognizer(self.longPressGesture)
        self.addGestureRecognizer(self.dismissingGesture)
        
        self.singleTapGesture.require(toFail: self.doubleTapGesture)
        
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: "轻点两下退出预览")
        }
    }
    
}

extension MediaBrowserView {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.dimmingView?.frame = self.bounds
        
        if self.collectionView.bounds.size != self.bounds.size {
            self.isChangingCollectionViewBounds = true
            self.collectionView.frame = self.bounds
            self.isChangingCollectionViewBounds = false
            self.scrollToPage(at: self.currentPage, animated: false)
        }
    }
    
}

extension MediaBrowserView {
    
    public func setCurrentPage(_ index: Int, animated: Bool = true) {
        self.isNeededScrollToItem = false
        self.currentPage = index
        self.isNeededScrollToItem = true
        
        /// 滚动到指定位置
        self.scrollToPage(at: index, animated: animated)
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
    }
    
    public func reloadPages(at indexs: [Int]) {
        var indexPaths: [IndexPath] = []
        for index in indexs {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        self.collectionView.reloadItems(at: indexPaths)
    }
    
    public func index(for pageCell: UICollectionViewCell) -> Int {
        if let indexPath: IndexPath = self.collectionView.indexPath(for: pageCell) {
            return indexPath.item
        }
        return NSNotFound
    }
    
    public func pageCellForItem<Cell: UICollectionViewCell>(at index: Int) -> Cell? {
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        return self.collectionView.cellForItem(at: indexPath) as? Cell
    }
    
    public func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type,
                                                                reuseIdentifier: String? = nil,
                                                                at index: Int) -> Cell {
        let identifier: String = reuseIdentifier ?? "Item_\(cellClass)"
        if !self.registeredCellIdentifiers.contains(identifier) {
            self.registeredCellIdentifiers.add(identifier)
            self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
        }
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
        return cell
    }
    
    public func dequeueReusableCell<Cell: UICollectionViewCell>(_ nibName: String,
                                                                bundle: Bundle? = Bundle.main,
                                                                reuseIdentifier: String? = nil,
                                                                at index: Int) -> Cell {
        let identifier: String = reuseIdentifier ?? "Item_Nib_\(nibName)"
        if !self.registeredCellIdentifiers.contains(identifier) {
            self.registeredCellIdentifiers.add(identifier)
            let nib = UINib(nibName: nibName, bundle: bundle)
            self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
        return cell
    }
    
    public func dequeueReusableCell<Cell: UICollectionViewCell>(_ storyboardReuseIdentifier: String, at index: Int) -> Cell {
        let identifier: String = storyboardReuseIdentifier
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
        return cell
    }
    
    public var currentPageCell: UICollectionViewCell? {
        let indexPath = IndexPath(item: self.currentPage, section: 0)
        return self.collectionView.cellForItem(at: indexPath)
    }
    
    fileprivate func scrollToPage(at index: Int, animated: Bool = true) {
        guard !self.collectionView.bounds.isEmpty else {
            return
        }
        if index >= 0 && index < self.totalUnitPage {
            /// iOS 14, 当isPagingEnabled为true, scrollToItem有bug
            /// https://stackoverflow.com/questions/41884645/uicollectionview-scroll-to-item-not-working-with-horizontal-direction
            let contentOffset = CGPoint(x: self.collectionView.bounds.width * CGFloat(index),
                                        y: self.collectionView.contentOffset.y)
            self.collectionView.setContentOffset(contentOffset, animated: animated)
        }
    }
    
}

extension MediaBrowserView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfPages(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.dataSource?.cellForPage(at: indexPath.item, in: self) ?? self.dequeueReusableCell(UICollectionViewCell.self, at: indexPath.item)
    }
    
}

extension MediaBrowserView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.plugin?.willDisplayCell(cell, forPageAt: indexPath.item, in: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.plugin?.didEndDisplayingCell(cell, forPageAt: indexPath.item, in: self)
    }
    
}

extension MediaBrowserView: UIScrollViewDelegate {
    
    private var pageOffsetRatio: CGFloat {
        let pageWidth: CGFloat = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0)).width
        let pageHorizontalMargin: CGFloat = self.collectionViewLayout.pageSpacing
        let contentOffsetX: CGFloat = self.collectionView.contentOffset.x
        let pageOffsetRatio: CGFloat = contentOffsetX / (pageWidth + pageHorizontalMargin)
        return pageOffsetRatio
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 横竖屏旋转会触发scrollViewDidScroll, 会导致self.currentPage被改变, 所以这里加个isChangingCollectionViewBounds控制下。
        guard scrollView == self.collectionView && !self.collectionView.bounds.isEmpty && !self.isChangingCollectionViewBounds else {
            return
        }
        
        let betweenOrEqual =  { (minimumValue: CGFloat, value: CGFloat, maximumValue: CGFloat) -> Bool in
            return minimumValue <= value && value <= maximumValue
        }
        let pageOffsetRatio: CGFloat = self.pageOffsetRatio
        let fastToRight: Bool = (floor(pageOffsetRatio) - floor(self.previousPageOffsetRatio) >= 1.0) && (floor(pageOffsetRatio) - self.previousPageOffsetRatio > 0.5)
        let turnPageToRight: Bool = fastToRight || betweenOrEqual(self.previousPageOffsetRatio, floor(pageOffsetRatio) + 0.5, pageOffsetRatio)
        let fastToLeft: Bool = (floor(self.previousPageOffsetRatio) - floor(pageOffsetRatio) >= 1.0) && (self.previousPageOffsetRatio - ceil(pageOffsetRatio) > 0.5)
        let turnPageToLeft: Bool = fastToLeft || betweenOrEqual(pageOffsetRatio, floor(pageOffsetRatio) + 0.5, self.previousPageOffsetRatio)
        
        if  turnPageToRight || turnPageToLeft {
            let previousIndex = min(Int(round(self.previousPageOffsetRatio)), self.totalUnitPage - 1)
            let index = Int(round(pageOffsetRatio))
            if index >= 0 && index < self.totalUnitPage {
                self.isNeededScrollToItem = false
                self.currentPage = index
                self.isNeededScrollToItem = true
                self.plugin?.willScrollHalfFrom(previousIndex, toIndex: index, in: self)
            }
        }
        self.previousPageOffsetRatio = pageOffsetRatio
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.collectionView else {
            return
        }
        
        self.plugin?.didScrollTo(self.currentPage, in: self)
    }
    
}

extension MediaBrowserView: UIGestureRecognizerDelegate {
    
    @objc public func handleSingleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        self.plugin?.singleTouch(gestureRecognizer, in: self)
    }
    
    @objc public func handleDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        self.plugin?.doubleTouch(gestureRecognizer, in: self)
    }
    
    @objc public func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.plugin?.longPress(gestureRecognizer, in: self)
        }
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.dismissingGesture {
            return self.plugin?.dismissingShouldBegin(self.dismissingGesture, in: self) ?? true
        } else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }
    
    @objc func handleDismissingGesture(gestureRecognizer: UIPanGestureRecognizer) {
        self.plugin?.dismissingChanged(gestureRecognizer, in: self)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let _ = touch.view as? UISlider {
            return false
        } else {
            return true
        }
    }
    
}
