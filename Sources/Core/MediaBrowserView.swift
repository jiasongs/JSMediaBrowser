//
//  MediaBrowserView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import JSCoreKit

@objc open class MediaBrowserView: UIView {
    
    @objc open weak var dataSource: MediaBrowserViewDataSource?
    @objc open weak var delegate: MediaBrowserViewDelegate?
    @objc open weak var gestureDelegate: MediaBrowserViewGestureDelegate?
    
    @objc open var singleTapGesture: UITapGestureRecognizer?
    @objc open var doubleTapGesture: UITapGestureRecognizer?
    @objc open var longPressGesture: UILongPressGestureRecognizer?
    @objc open var dismissingGesture: UIPanGestureRecognizer?
    @objc open var dismissingGestureEnabled: Bool = true
    
    @objc open var dimmingView: UIView? {
        didSet {
            if let dimmingView = self.dimmingView {
                dimmingView.removeFromSuperview()
                self.insertSubview(dimmingView, at: 0)
                self.setNeedsLayout()
            }
        }
    }
    @objc private(set) open var collectionView: PagingCollectionView?
    @objc private(set) open var collectionViewLayout: PagingLayout?
    
    @objc public var currentPage: Int = 0 {
        didSet {
            if isNeededScrollToItem {
                self.setCurrentPage(self.currentPage, animated: false)
            }
        }
    }
    @objc public var totalUnitPage: Int {
        if let numberOfItems = self.collectionView?.numberOfItems(inSection: 0) {
            return numberOfItems
        }
        return 0
    }
    
    private var isChangingCollectionViewFrame: Bool = false
    private var previousPageOffsetRatio: CGFloat = 0
    private var isNeededScrollToItem: Bool = true
    private var gestureBeganLocation: CGPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize(frame: CGRect.zero)
    }
    
    func didInitialize(frame: CGRect) -> Void {
        self.dimmingView = UIView()
        self.dimmingView?.backgroundColor = .black
        
        self.collectionViewLayout = PagingLayout()
        self.collectionView = PagingCollectionView(frame: frame, collectionViewLayout: self.collectionViewLayout!)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.addSubview(self.collectionView!)
        
        self.singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTapGesture))
        self.singleTapGesture?.delegate = self
        self.singleTapGesture?.numberOfTapsRequired = 1
        self.singleTapGesture?.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.singleTapGesture!)
        
        self.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTapGesture))
        self.doubleTapGesture?.numberOfTapsRequired = 2
        self.doubleTapGesture?.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.doubleTapGesture!)
        
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture))
        self.longPressGesture?.minimumPressDuration = 1
        self.addGestureRecognizer(self.longPressGesture!)
        
        self.dismissingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDismissingGesture))
        self.dismissingGesture?.minimumNumberOfTouches = 1
        self.dismissingGesture?.maximumNumberOfTouches = 1
        self.dismissingGesture?.delegate = self
        self.addGestureRecognizer(self.dismissingGesture!)
        
        self.singleTapGesture?.require(toFail: doubleTapGesture!)
    }
    
}

extension MediaBrowserView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let dimmingView = self.dimmingView {
            dimmingView.frame = self.bounds
        }
        if let collectionView = self.collectionView {
            if !collectionView.bounds.size.equalTo(self.bounds.size) {
                self.isChangingCollectionViewFrame = true
                /// 必须先 invalidateLayout，再更新 collectionView.frame，否则横竖屏旋转前后的图片不一致（因为 scrollViewDidScroll: 时 contentSize、contentOffset 那些是错的）
                self.collectionViewLayout?.invalidateLayout()
                self.collectionView?.frame = self.bounds
                self.scrollToPage(at: self.currentPage, animated: false)
                self.isChangingCollectionViewFrame = false
            }
        }
    }
    
}

extension MediaBrowserView {
    
    @objc open func setCurrentPage(_ index: Int, animated: Bool) -> Void {
        /// iOS 14, 当isPagingEnabled为true, 若不刷新则无法滚动到相应Item
        /// https://stackoverflow.com/questions/41884645/uicollectionview-scroll-to-item-not-working-with-horizontal-direction
        self.reloadData()
        /// 滚动到指定位置
        self.scrollToPage(at: index, animated: animated)
        self.isNeededScrollToItem = false
        self.currentPage = index
        self.isNeededScrollToItem = true
    }
    
    @objc(scrollToPageAtIndex:animated:)
    open func scrollToPage(at index: Int, animated: Bool) -> Void {
        if let collectionView = self.collectionView {
            /// 第一次产生实际性滚动的时候, 需要赋值当前的偏移率
            if self.previousPageOffsetRatio == 0 {
                self.previousPageOffsetRatio = self.pageOffsetRatio
            }
            if index < self.totalUnitPage {
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
                /// 立即滚动, 若不调用某些场景下可能无法滚动
                collectionView.layoutIfNeeded()
            }
        }
    }
    
    @objc open func reloadData() -> Void {
        self.collectionView?.reloadData()
    }
    
    @objc(reloadPagesAtIndexs:)
    open func reloadPages(at indexs: Array<Int>) {
        var indexPaths: Array<IndexPath> = []
        for index in indexs {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        self.collectionView?.reloadItems(at: indexPaths)
    }
    
    @objc(indexForPageCell:)
    open func index(for pageCell: UICollectionViewCell) -> Int {
        if let indexPath: IndexPath = self.collectionView?.indexPath(for: pageCell) {
            return indexPath.item
        }
        return NSNotFound
    }
    
    @objc(pageCellForItemAtIndex:)
    open func pageCellForItem(at index: Int) -> UICollectionViewCell? {
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        return self.collectionView?.cellForItem(at: indexPath)
    }
    
    @objc open func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        let nibPath: String? = Bundle(for: cellClass).path(forResource: NSStringFromClass(cellClass), ofType: "nib")
        if nibPath != nil {
            let nib: UINib? = UINib(nibName: NSStringFromClass(cellClass), bundle: Bundle(for: cellClass))
            self.collectionView?.register(nib, forCellWithReuseIdentifier: identifier)
        } else {
            self.collectionView?.register(cellClass, forCellWithReuseIdentifier: identifier)
        }
    }
    
    @objc(dequeueReusableCell:atIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: 0)
        return self.collectionView?.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) ?? UICollectionViewCell()
    }
    
    @objc open var currentPageCell: UICollectionViewCell? {
        let indexPath = IndexPath(item: self.currentPage, section: 0)
        return self.collectionView?.cellForItem(at: indexPath)
    }
    
    @objc open func resetDismissingGesture(withAnimations animations: (() -> Void)?) -> Void {
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
        guard let collectionView = self.collectionView else { return 0 }
        guard let collectionViewLayout = self.collectionViewLayout else { return 0 }
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
            self.resetDismissingGesture(withAnimations: nil)
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
        if let _ = touch.view as? UISlider {
            return false
        }
        return true
    }
    
    private func endDismissingGesture(_ gesture: UIPanGestureRecognizer, verticalDistance: CGFloat) -> Void {
        if self.toggleDismissingGestureDelegate(gesture, verticalDistance: verticalDistance) {
            self.gestureBeganLocation = CGPoint.zero
        } else {
            self.resetDismissingGesture(withAnimations: nil)
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
