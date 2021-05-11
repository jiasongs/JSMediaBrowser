//
//  MediaBrowserView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import JSCoreKit

@objc(JSMediaBrowserView)
open class MediaBrowserView: UIView {
    
    @objc open weak var dataSource: MediaBrowserViewDataSource? {
        didSet {
            self.collectionView.dataSource = self
        }
    }
    @objc open weak var delegate: MediaBrowserViewDelegate? {
        didSet {
            self.collectionView.delegate = self
        }
    }
    @objc open weak var gestureDelegate: MediaBrowserViewGestureDelegate?
    
    @objc private(set) lazy open var collectionView: PagingCollectionView = {
        return PagingCollectionView(frame: frame, collectionViewLayout: self.collectionViewLayout)
    }()
    
    @objc private(set) lazy open var collectionViewLayout: PagingLayout  = {
        return PagingLayout()
    }()
    
    @objc open var dimmingView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let dimmingView = self.dimmingView {
                self.insertSubview(dimmingView, at: 0)
            }
        }
    }
    
    @objc lazy open var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTapGesture))
        gesture.delegate = self
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    
    @objc lazy open var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTapGesture))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    
    @objc lazy open var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture))
        gesture.minimumPressDuration = 1
        return gesture
    }()
    
    @objc lazy open var dismissingGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismissingGesture))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    @objc lazy open var dismissingGestureEnabled: Bool = true
    
    @objc public var currentPage: Int = 0 {
        didSet {
            if self.isNeededScrollToItem {
                self.setCurrentPage(self.currentPage, animated: false)
            }
        }
    }
    @objc public var totalUnitPage: Int {
        return self.collectionView.numberOfItems(inSection: 0)
    }
    
    private var isChangingCollectionViewFrame: Bool = false
    private var previousPageOffsetRatio: CGFloat = 0
    private var isNeededScrollToItem: Bool = true
    private var gestureBeganLocation: CGPoint = CGPoint.zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    open func didInitialize(frame: CGRect) -> Void {
        self.dimmingView = UIView()
        self.dimmingView?.backgroundColor = .black
        
        self.addSubview(self.collectionView)
        
        self.addGestureRecognizer(self.singleTapGesture)
        self.addGestureRecognizer(self.doubleTapGesture)
        self.addGestureRecognizer(self.longPressGesture)
        self.addGestureRecognizer(self.dismissingGesture)
        
        self.singleTapGesture.require(toFail: doubleTapGesture)
    }
    
}

extension MediaBrowserView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.dimmingView?.frame = self.bounds
        let bounds: CGRect = self.bounds
        if self.collectionView.bounds.size != bounds.size {
            self.isChangingCollectionViewFrame = true
            /// 必须先 invalidateLayout，再更新 collectionView.frame，否则横竖屏旋转前后的图片不一致（因为 scrollViewDidScroll: 时 contentSize、contentOffset 那些是错的）
            self.collectionViewLayout.invalidateLayout()
            self.collectionView.frame = bounds
            self.scrollToPage(at: self.currentPage, animated: false)
            self.isChangingCollectionViewFrame = false
        }
    }
    
}

extension MediaBrowserView {
    
    @objc open func setCurrentPage(_ index: Int, animated: Bool = true) -> Void {
        /// iOS 14, 当isPagingEnabled为true, 若不reloadData则无法滚动到相应Item
        /// https://stackoverflow.com/questions/41884645/uicollectionview-scroll-to-item-not-working-with-horizontal-direction
        self.reloadData()
        /// 滚动到指定位置
        self.scrollToPage(at: index, animated: animated)
        self.isNeededScrollToItem = false
        self.currentPage = index
        self.isNeededScrollToItem = true
    }
    
    private func scrollToPage(at index: Int, animated: Bool = true) -> Void {
        /// 第一次产生实际性滚动的时候, 需要赋值当前的偏移率
        if self.previousPageOffsetRatio == 0 {
            self.previousPageOffsetRatio = self.pageOffsetRatio
        }
        if index < self.totalUnitPage {
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            /// 立即滚动, 若不调用某些场景下可能无法滚动
            self.collectionView.layoutIfNeeded()
        }
    }
    
    @objc open func reloadData() -> Void {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.collectionView.reloadData()
        CATransaction.commit()
    }
    
    @objc(reloadPagesAtIndexs:)
    open func reloadPages(at indexs: Array<Int>) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        var indexPaths: Array<IndexPath> = []
        for index in indexs {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        self.collectionView.reloadItems(at: indexPaths)
        CATransaction.commit()
    }
    
    @objc(indexForPageCell:)
    open func index(for pageCell: UICollectionViewCell) -> Int {
        if let indexPath: IndexPath = self.collectionView.indexPath(for: pageCell) {
            return indexPath.item
        }
        return NSNotFound
    }
    
    @objc(pageCellForItemAtIndex:)
    open func pageCellForItem(at index: Int) -> UICollectionViewCell? {
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        return self.collectionView.cellForItem(at: indexPath)
    }
    
    @objc open func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        let nibPath: String? = Bundle(for: cellClass).path(forResource: NSStringFromClass(cellClass), ofType: "nib")
        if nibPath != nil {
            let nib: UINib? = UINib(nibName: NSStringFromClass(cellClass), bundle: Bundle(for: cellClass))
            self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        } else {
            self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
        }
    }
    
    @objc(dequeueReusableCell:atIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: 0)
        return self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    @objc open var currentPageCell: UICollectionViewCell? {
        let indexPath = IndexPath(item: self.currentPage, section: 0)
        return self.collectionView.cellForItem(at: indexPath)
    }
    
    @objc open func resetDismissingGesture(withAnimations animations: (() -> Void)? = nil) -> Void {
        self.gestureBeganLocation = CGPoint.zero
        UIView.animate(withDuration: 0.25, delay: 0, options: AnimationOptionsCurveOut, animations: {
            self.currentPageCell?.transform = CGAffineTransform.identity
            self.dimmingView?.alpha = 1.0
            if let block = animations {
                block()
            }
        }, completion: nil)
    }
    
}

extension MediaBrowserView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.numberOfMediaItemsInBrowserView(self) ?? 0
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
        if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:willDisplay:forItemAt:))) {
            delegate.mediaBrowserView?(self, willDisplay: cell, forItemAt: indexPath.item)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:didEndDisplaying:forItemAt:))) {
            delegate.mediaBrowserView?(self, didEndDisplaying: cell, forItemAt: indexPath.item)
        }
    }
    
}

extension MediaBrowserView: UIScrollViewDelegate {
    
    private var pageOffsetRatio: CGFloat {
        let pageWidth: CGFloat = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0)).width
        let pageHorizontalMargin: CGFloat = collectionViewLayout.pageSpacing
        let contentOffsetX: CGFloat = collectionView.contentOffset.x
        let pageOffsetRatio: CGFloat = contentOffsetX / (pageWidth + pageHorizontalMargin)
        return pageOffsetRatio
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != self.collectionView || self.isChangingCollectionViewFrame {
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
                if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:willScrollHalf:toIndex:))) {
                    delegate.mediaBrowserView?(self, willScrollHalf: previousIndex, toIndex: index)
                }
            }
        }
        self.previousPageOffsetRatio = pageOffsetRatio
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != self.collectionView {
            return
        }
        if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:didScrollTo:))) {
            delegate.mediaBrowserView?(self, didScrollTo: self.currentPage)
        }
    }
    
}

extension MediaBrowserView: UIGestureRecognizerDelegate {
    
    @objc public func handleSingleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        if let delegate = self.gestureDelegate, delegate.responds(to: #selector(MediaBrowserViewGestureDelegate.mediaBrowserView(_:singleTouch:))) {
            delegate.mediaBrowserView?(self, singleTouch: gestureRecognizer)
        }
    }
    
    @objc public func handleDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) -> Void {
        if let delegate = self.gestureDelegate, delegate.responds(to: #selector(MediaBrowserViewGestureDelegate.mediaBrowserView(_:doubleTouch:))) {
            delegate.mediaBrowserView?(self, doubleTouch: gestureRecognizer)
        }
    }
    
    @objc public func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) -> Void {
        if gestureRecognizer.state == .began {
            if let delegate = self.gestureDelegate, delegate.responds(to: #selector(MediaBrowserViewGestureDelegate.mediaBrowserView(_:longPress:))) {
                delegate.mediaBrowserView?(self, longPress: gestureRecognizer)
            }
        }
    }
    
    @objc func handleDismissingGesture(gesture: UIPanGestureRecognizer) -> Void {
        switch gesture.state {
        case .began:
            self.gestureBeganLocation = gesture.location(in: gesture.view)
            self.toggleDismissingGestureDelegate(gesture, verticalDistance: 0)
            break
        case .changed:
            if let pageCell = self.currentPageCell {
                let location: CGPoint = gesture.location(in: self)
                let horizontalDistance: CGFloat = location.x - self.gestureBeganLocation.x
                var verticalDistance: CGFloat = location.y - self.gestureBeganLocation.y
                let height: NSNumber = NSNumber(value: Float(self.bounds.height / 2))
                var ratio: CGFloat = 1.0
                var alpha: CGFloat = 1.0
                if  verticalDistance > 0 {
                    ratio = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.4], extrapolateLeft: .clamp, extrapolateRight: .clamp)
                    alpha = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.2], extrapolateLeft: .clamp, extrapolateRight: .clamp)
                } else {
                    let a: CGFloat = self.gestureBeganLocation.y + 200
                    let b: CGFloat = 1 - pow((a - abs(verticalDistance)) / a, 2)
                    let c: CGFloat = self.bounds.height / 2
                    verticalDistance = -c * b
                }
                let transform = CGAffineTransform(translationX: horizontalDistance, y: verticalDistance).scaledBy(x: ratio, y: ratio)
                pageCell.transform = transform
                self.dimmingView?.alpha = alpha
                self.toggleDismissingGestureDelegate(gesture, verticalDistance: verticalDistance)
            }
            break
        case .ended:
            let location: CGPoint = gesture.location(in: self)
            let verticalDistance: CGFloat = location.y - self.gestureBeganLocation.y
            self.endDismissingGesture(gesture, verticalDistance: verticalDistance)
            break
        default:
            self.resetDismissingGesture()
            break
        }
    }
    
    @objc public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.dismissingGesture {
            return self.dismissingGestureEnabled
        }
        return true
    }
    
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let delegate = self.gestureDelegate, delegate.responds(to: #selector(MediaBrowserViewGestureDelegate.mediaBrowserView(_:gestureRecognizer:shouldReceive:))) {
            return delegate.mediaBrowserView?(self, gestureRecognizer: gestureRecognizer, shouldReceive: touch) ?? true
        }
        return true
    }
    
    private func endDismissingGesture(_ gesture: UIPanGestureRecognizer, verticalDistance: CGFloat) -> Void {
        if self.toggleDismissingGestureDelegate(gesture, verticalDistance: verticalDistance) {
            self.gestureBeganLocation = CGPoint.zero
        } else {
            self.resetDismissingGesture()
        }
    }
    
    @discardableResult
    private func toggleDismissingGestureDelegate(_ gesture: UIPanGestureRecognizer, verticalDistance: CGFloat) -> Bool {
        if let delegate = self.gestureDelegate, delegate.responds(to: #selector(MediaBrowserViewGestureDelegate.mediaBrowserView(_:dismissing:verticalDistance:))) {
            delegate.mediaBrowserView?(self, dismissing: gesture, verticalDistance: verticalDistance)
            return true
        } else {
            return false
        }
    }
    
}
