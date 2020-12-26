//
//  MediaBrowserViewController.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/11.
//

import UIKit
import JSCoreKit

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
                toolView.sourceItemsDidChange(for: self)
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
    /// mark
    @objc open var addWebImageMediatorBlock: BuildWebImageMediatorBlock?
    @objc open var addToolViewsBlock: BuildToolViewsBlock?
    @objc open var progressTintColor: UIColor?
    
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
    
    @objc open func show(from sender: UIViewController, animated: Bool) {
        sender.present(self, animated: animated, completion: nil)
    }
    
    @objc open func hide(animated: Bool) {
        self.dismiss(animated: animated, completion: nil)
    }
    
    @objc open var toolViews: Array<UIView & ToolViewProtocol> {
        get {
            var resultArray = Array<UIView & ToolViewProtocol>()
            for item in self.view.subviews.enumerated() {
                if let subview = item.element as? (UIView & ToolViewProtocol) {
                    resultArray.append(subview)
                }
            }
            return resultArray
        }
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
            /// 注册Cell
            browserView.registerClass(ImageCell.self, forCellWithReuseIdentifier: imageCellIdentifier)
        }
        /// 工具视图
        var buildBlock: BuildToolViewsBlock?
        if let block = self.addToolViewsBlock {
            buildBlock = block
        } else if let block = MediaBrowserAppearance.appearance.addToolViewsBlock {
            buildBlock = block
        }
        if buildBlock != nil {
            let toolViews: Array<UIView & ToolViewProtocol> = buildBlock!(self)
            for toolView in toolViews {
                self.view.addSubview(toolView)
                toolView.viewDidLoad(for: self)
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let browserView = self.browserView {
            browserView.js_frameApplyTransform = self.view.bounds
        }
        for toolView in self.toolViews {
            if toolView.responds(to: #selector(ToolViewProtocol.viewDidLayoutSubviews(for:))) {
                toolView.viewDidLayoutSubviews?(for: self)
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let browserView = self.browserView {
            browserView.reloadData()
            browserView.collectionView?.layoutIfNeeded()
        }
        for toolView in self.toolViews {
            if toolView.responds(to: #selector(ToolViewProtocol.viewWillAppear(for:))) {
                toolView.viewWillAppear?(for: self)
            }
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        for toolView in self.toolViews {
            if toolView.responds(to: #selector(ToolViewProtocol.viewWillDisappear(for:))) {
                toolView.viewWillDisappear?(for: self)
            }
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    public func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int {
        return loaderItems?.count ?? 0
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt index: Int) -> UICollectionViewCell {
        var cell: BaseCell?
        guard let loaderItem = loaderItems?[index] else { return UICollectionViewCell() }
        if let loaderItem = loaderItem as? ImageLoaderEntity, let _ = loaderItem.sourceItem as? ImageEntity {
            cell = browserView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: index) as? BaseCell
            if let tintColor = self.progressTintColor {
                cell?.progressTintColor = tintColor
            } else if let tintColor = MediaBrowserAppearance.appearance.progressTintColor {
                cell?.progressTintColor = tintColor
            }
            cell?.updateCell(loaderEntity: loaderItem, at: index)
        }
        return cell!
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
            if toolView.responds(to: #selector(ToolViewProtocol.willScrollHalf(for:fromIndex:toIndex:))) {
                toolView.willScrollHalf?(for: self, fromIndex: fromIndex, toIndex: toIndex)
            }
        }
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int) {
        for toolView in self.toolViews {
            if toolView.responds(to: #selector(ToolViewProtocol.didScrollTo(for:index:))) {
                toolView.didScrollTo?(for: self, index: index)
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
            if toolView.responds(to: #selector(ToolViewProtocol.didLongPress(for:gestureRecognizer:))) {
                toolView.didLongPress?(for: self, gestureRecognizer: gestureRecognizer)
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

extension MediaBrowserViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitioningAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitioningAnimator
    }
    
}

extension MediaBrowserViewController: TransitionAnimatorDelegate {
    
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
