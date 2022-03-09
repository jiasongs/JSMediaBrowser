//
//  MediaBrowserView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import JSCoreKit

open class MediaBrowserView: UIView {
    
    open weak var dataSource: MediaBrowserViewDataSource? {
        didSet {
            self.collectionView.dataSource = self
        }
    }
    open weak var delegate: MediaBrowserViewDelegate? {
        didSet {
            self.collectionView.delegate = self
        }
    }
    open weak var gestureDelegate: MediaBrowserViewGestureDelegate?
    
    private(set) open lazy var collectionView: PagingCollectionView = {
        return PagingCollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout)
    }()
    
    private(set) open lazy var collectionViewLayout: PagingLayout  = {
        return PagingLayout()
    }()
    
    open var dimmingView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let dimmingView = self.dimmingView {
                self.insertSubview(dimmingView, at: 0)
            }
        }
    }
    
    open lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTapGesture))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    
    open lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTapGesture))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    
    open lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture))
        gesture.minimumPressDuration = 1
        return gesture
    }()
    
    open lazy var dismissingGesture: UIPanGestureRecognizer = {
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
    
    open func didInitialize(frame: CGRect) {
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
    
    open override func layoutSubviews() {
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
    
    open func setCurrentPage(_ index: Int, animated: Bool = true) {
        self.isNeededScrollToItem = false
        self.currentPage = index
        self.isNeededScrollToItem = true
        
        /// 滚动到指定位置
        self.scrollToPage(at: index, animated: animated)
    }
    
    open func reloadData() {
        self.collectionView.reloadData()
    }
    
    open func reloadPages(at indexs: [Int]) {
        var indexPaths: [IndexPath] = []
        for index in indexs {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        self.collectionView.reloadItems(at: indexPaths)
    }
    
    open func index(for pageCell: UICollectionViewCell) -> Int {
        if let indexPath: IndexPath = self.collectionView.indexPath(for: pageCell) {
            return indexPath.item
        }
        return NSNotFound
    }
    
    open func pageCellForItem<Cell: UICollectionViewCell>(at index: Int) -> Cell? {
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        return self.collectionView.cellForItem(at: indexPath) as? Cell
    }
    
    open func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type,
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
    
    open func dequeueReusableCell<Cell: UICollectionViewCell>(_ nibName: String,
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
    
    open func dequeueReusableCell<Cell: UICollectionViewCell>(_ storyboardReuseIdentifier: String, at index: Int) -> Cell {
        let identifier: String = storyboardReuseIdentifier
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
        return cell
    }
    
    open var currentPageCell: UICollectionViewCell? {
        let indexPath = IndexPath(item: self.currentPage, section: 0)
        if let cell = self.collectionView.cellForItem(at: indexPath) {
            return cell
        } else {
            return self.collectionView.visibleCells.last
        }
    }
    
    open func pageCellForItem(at point: CGPoint) -> UICollectionViewCell? {
        if let indexPath =  self.collectionView.indexPathForItem(at: point) {
            return self.collectionView.cellForItem(at: indexPath)
        } else {
            return nil
        }
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
        return self.dataSource?.numberOfPagesInMediaBrowserView(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.dataSource?.mediaBrowserView(self, cellForItemAt: indexPath.item) ?? UICollectionViewCell()
    }
    
}

extension MediaBrowserView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.mediaBrowserView(self, willDisplay: cell, forItemAt: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.mediaBrowserView(self, didEndDisplaying: cell, forItemAt: indexPath.item)
    }
    
}

extension MediaBrowserView: UIScrollViewDelegate {
    
    private var pageOffsetRatio: CGFloat {
        let pageWidth: CGFloat = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0)).width
        let contentOffsetX: CGFloat = self.collectionView.contentOffset.x
        let pageOffsetRatio: CGFloat = contentOffsetX / pageWidth
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
            assert(previousIndex != index, "当前index与将要滚动到的index相同, 可能存在问题, 请检查self.pageOffsetRatio")
            if index >= 0 && index < self.totalUnitPage {
                self.isNeededScrollToItem = false
                self.currentPage = index
                self.isNeededScrollToItem = true
                self.delegate?.mediaBrowserView(self, willScrollHalf: previousIndex, toIndex: index)
            }
        }
        self.previousPageOffsetRatio = pageOffsetRatio
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.collectionView else {
            return
        }
        
        self.delegate?.mediaBrowserView(self, didScrollTo: self.currentPage)
    }
    
}

extension MediaBrowserView: UIGestureRecognizerDelegate {
    
    @objc public func handleSingleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        self.gestureDelegate?.mediaBrowserView(self, singleTouch: gestureRecognizer)
    }
    
    @objc public func handleDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        self.gestureDelegate?.mediaBrowserView(self, doubleTouch: gestureRecognizer)
    }
    
    @objc public func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.gestureDelegate?.mediaBrowserView(self, longPress: gestureRecognizer)
        }
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.dismissingGesture {
            return self.gestureDelegate?.mediaBrowserView(self, dismissingShouldBegin: self.dismissingGesture) ?? true
        } else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }
    
    @objc func handleDismissingGesture(gestureRecognizer: UIPanGestureRecognizer) {
        self.gestureDelegate?.mediaBrowserView(self, dismissingChanged: gestureRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let _ = touch.view as? UISlider {
            return false
        } else {
            return true
        }
    }
    
}
