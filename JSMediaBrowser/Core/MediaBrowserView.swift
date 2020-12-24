//
//  MediaBrowserView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import JSCoreKit

open class MediaBrowserView: UIView {
    
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
    @objc private(set) var collectionView: PagingCollectionView?
    @objc private(set) var collectionViewLayout: PagingLayout?
    
    @objc public var currentPage: Int = 0 {
        didSet {
            if isNeededScrollToItem {
                self.setCurrentPage(self.currentPage, animated: false)
            }
        }
    }
    
    private var isChangingCollectionViewBounds: Bool = false
    private var previousIndexWhenScrolling: CGFloat = 0
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
        self.dismissingGesture?.delegate = self
        self.addGestureRecognizer(self.dismissingGesture!)
        
        self.singleTapGesture?.require(toFail: doubleTapGesture!)
    }
    
}

extension MediaBrowserView {
    
    @objc open func setCurrentPage(_ index: Int, animated: Bool) -> Void {
        self.isNeededScrollToItem = false
        self.currentPage = index
        self.isNeededScrollToItem = true
        self.reloadData()
        guard let numberOfItems = self.collectionView?.numberOfItems(inSection: 0) else { return }
        if index < numberOfItems {
            let indexPath = IndexPath(item: self.currentPage, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            self.collectionView?.layoutIfNeeded()
        }
    }
    
    @objc open func reloadData() -> Void {
        self.collectionView?.reloadData()
    }
    
    @objc open func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        self.collectionView?.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    @objc open func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: 0)
        return self.collectionView?.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) ?? UICollectionViewCell()
    }
    
    @objc open var currentPageCell: UICollectionViewCell? {
        get {
            let indexPath = IndexPath(item: self.currentPage, section: 0)
            return self.collectionView?.cellForItem(at: indexPath)
        }
    }
    
    @objc open func resetDismissingGesture() -> Void {
        self.gestureBeganLocation = CGPoint.zero
        UIView.animate(withDuration: 0.25, delay: 0, options: AnimationOptionsCurveOut, animations: {
            self.currentPageCell?.transform = CGAffineTransform.identity
            self.dimmingView?.alpha = 1.0
        }, completion: nil)
    }
    
}

extension MediaBrowserView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let dimmingView = self.dimmingView {
            dimmingView.frame = self.bounds
        }
        if let collectionView = self.collectionView {
            let isSizeChanged = !collectionView.bounds.size.equalTo(self.bounds.size)
            if isSizeChanged {
                self.isChangingCollectionViewBounds = true
                self.collectionViewLayout?.invalidateLayout()
                self.collectionView?.frame = self.bounds
                let numberOfItems = collectionView.numberOfItems(inSection: 0)
                if self.currentPage < numberOfItems {
                    let indexPath = IndexPath(item: self.currentPage, section: 0)
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                }
                self.isChangingCollectionViewBounds = false
            }
        }
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
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != self.collectionView {
            return
        }
        if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:didScrollTo:))) {
            delegate.mediaBrowserView?(self, didScrollTo: self.currentPage)
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
        let pageWidth: CGFloat = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0)).width
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
                self.currentPage = Int(index)
                self.isNeededScrollToItem = true
                if let delegate = self.delegate, delegate.responds(to: #selector(MediaBrowserViewDelegate.mediaBrowserView(_:willScrollHalf:toIndex:))) {
                    let fromIndex = Int(round(self.previousIndexWhenScrolling))
                    let toIndex = Int(index)
                    delegate.mediaBrowserView?(self, willScrollHalf: fromIndex, toIndex: toIndex)
                }
            }
        }
        self.previousIndexWhenScrolling = index
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
            if let midiaCell = self.currentPageCell {
                let location: CGPoint = gesture.location(in: self)
                let horizontalDistance: CGFloat = location.x - self.gestureBeganLocation.x
                var verticalDistance: CGFloat = location.y - self.gestureBeganLocation.y
                let height: NSNumber = NSNumber(value: Float(self.bounds.height / 2))
                var ratio: CGFloat = 1.0
                var alpha: CGFloat = 1.0
                if (verticalDistance > 0) {
                    ratio = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.5], extrapolateLeft: .clamp, extrapolateRight: .clamp)
                    alpha = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.2], extrapolateLeft: .clamp, extrapolateRight: .clamp)
                } else {
                    let a: CGFloat = self.gestureBeganLocation.y + 200
                    let b: CGFloat = 1 - pow((a - abs(verticalDistance)) / a, 2)
                    let c: CGFloat = self.bounds.height / 2
                    verticalDistance = -c * b
                }
                let transform = CGAffineTransform(translationX: horizontalDistance, y: verticalDistance).scaledBy(x: ratio, y: ratio)
                midiaCell.transform = transform
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
