//
//  MediaBrowserViewController.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/11.
//

import UIKit
import JSCoreKit
import PhotosUI

@objc(MediaBrowserViewControllerTransitioningStyle)
public enum TransitioningStyle: Int {
    case zoom
    case fade
}

@objc open class MediaBrowserViewController: UIViewController {
    
    @objc open var browserView: MediaBrowserView?
    @objc open var sourceItems: Array<SourceProtocol>? {
        didSet {
            var array: Array<BaseLoaderEntity> = Array()
            sourceItems?.forEach({ (item) in
                if let _ = item as? ImageEntity {
                    let loader: ImageLoaderEntity = ImageLoaderEntity()
                    loader.sourceItem = item
                    if let block = self.addWebImageMediatorBlock {
                        loader.webImageMediator = block(self, item)
                    } else if let block = MediaBrowserAppearance.appearance.addWebImageMediatorBlock {
                        loader.webImageMediator = block(self, item)
                    }
                    array.append(loader)
                }
            })
            loaderItems = array
            for toolView in self.toolViews {
                if toolView.responds(to: #selector(ToolViewProtocol.sourceItemsDidChange(in:))) {
                    toolView.sourceItemsDidChange?(in: self)
                }
            }
        }
    }
    
    @objc open var transitioningAnimator: UIViewControllerAnimatedTransitioning? {
        didSet {
            if let animator = transitioningAnimator as? TransitionAnimator {
                animator.delegate = self
            }
        }
    }
    @objc open var presentingStyle: TransitioningStyle = .zoom {
        didSet {
            dismissingStyle = presentingStyle
            if let animator = transitioningAnimator as? TransitionAnimator {
                animator.presentingStyle = presentingStyle
            }
        }
    }
    @objc open var dismissingStyle: TransitioningStyle = .zoom {
        didSet {
            if let animator = transitioningAnimator as? TransitionAnimator {
                animator.dismissingStyle = dismissingStyle
            }
        }
    }
    @objc open var addImageViewInZoomViewBlock: BuildImageViewInZoomViewBlock?
    @objc open var addLivePhotoViewInZoomViewBlock: BuildLivePhotoViewInZoomViewBlock?
    @objc open var addWebImageMediatorBlock: BuildWebImageMediatorBlock?
    @objc open var addToolViewsBlock: BuildToolViewsBlock?
    @objc open var cellForItemAtIndexBlock: BuildCellBlock?
    @objc open var configureCellBlock: ConfigureCellBlock?
    @objc open var willDisplayEmptyViewBlock: DisplayEmptyViewBlock?
    
    private var loaderItems: Array<LoaderProtocol>?
    private var imageCellIdentifier = "ImageCell"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    func didInitialize() -> Void {
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
        self.transitioningDelegate = self
        
        transitioningAnimator = TransitionAnimator()
        browserView = MediaBrowserView()
    }
    
}

extension MediaBrowserViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
        if let browserView = self.browserView {
            browserView.delegate = self
            browserView.dataSource = self
            browserView.gestureDelegate = self
            self.view.addSubview(browserView)
        }
        /// 注册Cell
        self.registerClass(ImageCell.self, forCellWithReuseIdentifier: imageCellIdentifier)
        let reuseCellIdentifiers: Dictionary<Identifier, CellClassSting> = MediaBrowserAppearance.appearance.reuseCellIdentifiers
        for (key, value) in reuseCellIdentifiers {
            let cellClass: AnyClass = NSClassFromString(value) ?? UICollectionViewCell.self
            self.registerClass(cellClass, forCellWithReuseIdentifier: key)
        }
        /// 工具视图
        var buildBlock: BuildToolViewsBlock?
        if let block = self.addToolViewsBlock {
            buildBlock = block
        } else if let block = MediaBrowserAppearance.appearance.addToolViewsBlock {
            buildBlock = block
        }
        if let block = buildBlock {
            let toolViews: Array<UIView & ToolViewProtocol> = block(self)
            for toolView in toolViews {
                self.view.addSubview(toolView)
                toolView.didAddToSuperview(in: self)
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let browserView = self.browserView {
            browserView.js_frameApplyTransform = self.view.bounds
        }
        for toolView in self.toolViews {
            if toolView.responds(to: #selector(ToolViewProtocol.didLayoutSubviews(in:))) {
                toolView.didLayoutSubviews?(in: self)
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let browserView = self.browserView {
            browserView.reloadData()
            browserView.collectionView?.layoutIfNeeded()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
}

extension MediaBrowserViewController {
    
    @objc(showFromViewController:animated:)
    open func show(from sender: UIViewController, animated: Bool) {
        sender.present(self, animated: animated, completion: nil)
    }
    
    @objc open func hide(animated: Bool) {
        self.dismiss(animated: animated, completion: nil)
    }
    
    @objc open var toolViews: Array<UIView & ToolViewProtocol> {
        get {
            if !self.isViewLoaded {
                return []
            }
            var resultArray = Array<UIView & ToolViewProtocol>()
            for item in self.view.subviews.enumerated() {
                if let subview = item.element as? (UIView & ToolViewProtocol) {
                    resultArray.append(subview)
                }
            }
            return resultArray
        }
    }
    
    @objc public func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        self.browserView?.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    @objc(dequeueReusableCell:atIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        return self.browserView?.dequeueReusableCell(withReuseIdentifier: identifier, at: index) ?? UICollectionViewCell()
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    public func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int {
        return loaderItems?.count ?? 0
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt index: Int) -> UICollectionViewCell {
        var cell: UICollectionViewCell!
        if let block = self.cellForItemAtIndexBlock {
            cell = block(self, index)
        } else if let block = MediaBrowserAppearance.appearance.cellForItemAtIndexBlock {
            cell = block(self, index)
        }
        if cell == nil, let loaderItem = loaderItems?[index] as? ImageLoaderEntity {
            cell = self.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, at: index)
            /// 需要添加代理
            if let imageCell = cell as? ImageCell {
                imageCell.zoomImageView?.delegate = self
            }
            if let baseCell = cell as? BaseCell {
                self.addMonitorFor(baseCell: baseCell)
                baseCell.updateCell(loaderEntity: loaderItem, at: index)
            }
        }
        if let block = self.configureCellBlock {
            block(self, cell, index)
        } else if let block = MediaBrowserAppearance.appearance.configureCellBlock {
            block(self, cell, index)
        }
        return cell
    }
    
    private func addMonitorFor(baseCell cell: BaseCell) -> Void {
        cell.onEmptyPressAction = { [weak self] (cell: UICollectionViewCell) in
            if let index: Int = self?.browserView?.index(for: cell), index != NSNotFound {
                self?.browserView?.reloadItems(at: [index])
            }
        }
        cell.willDisplayEmptyViewBlock = { [weak self] (cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            if let block = self?.willDisplayEmptyViewBlock, let strongSelf = self {
                block(strongSelf, cell, emptyView, error)
            } else if let block = MediaBrowserAppearance.appearance.willDisplayEmptyViewBlock, let strongSelf = self {
                block(strongSelf, cell, emptyView, error)
            }
        }
        self.browserView?.dismissingGestureEnabled = false
        cell.didLoaderCompleted = { [weak self] (cell: UICollectionViewCell, object: Any?, error: NSError?) in
            if object != nil && error == nil {
                self?.browserView?.dismissingGestureEnabled = true
            }
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, willScrollHalf fromIndex: Int, toIndex: Int) {
        if let loaderEntity = loaderItems?[fromIndex], let sourceItem = loaderEntity.sourceItem {
            sourceItem.sourceView?.isHidden = false
        }
        if let loaderEntity = loaderItems?[toIndex], let sourceItem = loaderEntity.sourceItem {
            sourceItem.sourceView?.isHidden = true
        }
        for toolView in self.toolViews {
            if toolView.responds(to: #selector(ToolViewProtocol.willScrollHalf(fromIndex:toIndex:in:))) {
                toolView.willScrollHalf?(fromIndex: fromIndex, toIndex: toIndex, in: self)
            }
        }
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int) {
        for toolView in self.toolViews {
            if toolView.responds(to: #selector(ToolViewProtocol.didScrollTo(index:in:))) {
                toolView.didScrollTo?(index: index, in: self)
            }
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewGestureDelegate {
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        self.hide(animated: true)
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        if let imageCell = browserView.currentPageCell as? ImageCell {
            let gesturePoint: CGPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            imageCell.zoomImageView?.zoom(to: gesturePoint, from: gestureRecognizer.view, animated: true)
        }
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer) {
        for toolView in self.toolViews {
            if toolView.responds(to: #selector(ToolViewProtocol.didLongPress(gestureRecognizer:in:))) {
                toolView.didLongPress?(gestureRecognizer: gestureRecognizer, in: self)
            }
        }
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, dismissing gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat) {
        switch gestureRecognizer.state {
        case .changed:
            var alpha: CGFloat = 1
            let height: NSNumber = NSNumber(value: Float(browserView.bounds.height / 2))
            if (verticalDistance > 0) {
                alpha = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.2], extrapolateLeft: .clamp, extrapolateRight: .clamp)
            }
            for toolView in self.toolViews {
                toolView.alpha = alpha
            }
            break
        case .ended:
            if (verticalDistance > browserView.bounds.height / 2 / 3) {
                self.hide(animated: true)
            } else {
                browserView.resetDismissingGesture(withAnimations: { () -> Void in
                    for toolView in self.toolViews {
                        toolView.alpha = 1.0
                    }
                })
            }
            break
        default:
            break
        }
    }
    
}

extension MediaBrowserViewController: ZoomImageViewDelegate {
    
    @objc public func zoomImageViewLazyBuildImageView(_ zoomImageView: ZoomImageView) -> UIImageView {
        var imageView: UIImageView
        if let block = self.addImageViewInZoomViewBlock {
            imageView = block(self, zoomImageView)
        } else if let block = MediaBrowserAppearance.appearance.addImageViewInZoomViewBlock {
            imageView = block(self, zoomImageView)
        } else {
            imageView = UIImageView()
        }
        return imageView
    }
    
    @objc public func zoomImageViewLazyBuildLivePhotoView(_ zoomImageView: ZoomImageView) -> PHLivePhotoView {
        var livePhotoView: PHLivePhotoView
        if let block = self.addLivePhotoViewInZoomViewBlock {
            livePhotoView = block(self, zoomImageView)
        } else if let block = MediaBrowserAppearance.appearance.addLivePhotoViewInZoomViewBlock {
            livePhotoView = block(self, zoomImageView)
        } else {
            livePhotoView = PHLivePhotoView()
        }
        return livePhotoView
    }
    
}

extension MediaBrowserViewController: UIViewControllerTransitioningDelegate, TransitionAnimatorDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitioningAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitioningAnimator
    }
    
    /// mark: TransitionAnimatorDelegate
    
    public var sourceRect: CGRect {
        if let sourceItem = self.sourceItems?[browserView?.currentPage ?? 0] {
            return sourceItem.sourceRect
        }
        return CGRect.zero
    }
    
    public var sourceView: UIView? {
        if let sourceItem = self.sourceItems?[browserView?.currentPage ?? 0] {
            return sourceItem.sourceView
        }
        return nil
    }
    
    public var sourceCornerRadius: CGFloat {
        if let sourceItem = self.sourceItems?[browserView?.currentPage ?? 0] {
            if sourceItem.sourceCornerRadius > 0 {
                return sourceItem.sourceCornerRadius
            } else {
                return sourceItem.sourceView?.layer.cornerRadius ?? 0
            }
        }
        return 0
    }
    
    public var thumbImage: UIImage? {
        if let sourceItem: ImageEntity = self.sourceItems?[browserView?.currentPage ?? 0] as? ImageEntity {
            return (sourceItem.image != nil) ? sourceItem.image : sourceItem.thumbImage
        }
        return nil
    }
    
    public var animatorViews: Array<UIView>? {
        return self.toolViews
    }
    
    public var dimmingView: UIView? {
        return self.browserView?.dimmingView
    }
    
    public var zoomView: UIView? {
        if let cell = self.browserView?.currentPageCell {
            return cell
        }
        return nil
    }
    
    public var zoomContentView: UIView? {
        if let imageCell = self.browserView?.currentPageCell as? ImageCell {
            return imageCell.zoomImageView?.contentView
        }
        return nil
    }
    
}
