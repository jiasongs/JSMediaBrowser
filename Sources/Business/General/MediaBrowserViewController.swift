//
//  MediaBrowserViewController.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/11.
//

import UIKit
import JSCoreKit
import PhotosUI

#if BUSINESS_IMAGE
public typealias BuildImageViewForZoomViewBlock = (MediaBrowserViewController, ZoomImageView) -> UIImageView
public typealias BuildLivePhotoViewForZoomViewBlock = (MediaBrowserViewController, ZoomImageView) -> PHLivePhotoView
public typealias BuildWebImageMediatorBlock = (MediaBrowserViewController, SourceProtocol) -> WebImageMediatorProtocol
#endif
public typealias BuildToolViewsBlock = (MediaBrowserViewController) -> Array<UIView & ToolViewProtocol>
public typealias BuildCellBlock = (MediaBrowserViewController, Int) -> UICollectionViewCell?
public typealias ConfigureCellBlock = (MediaBrowserViewController, UICollectionViewCell, Int) -> Void
public typealias DisplayEmptyViewBlock = (MediaBrowserViewController, UICollectionViewCell, EmptyView, NSError) -> Void
public typealias LongPressBlock = (MediaBrowserViewController) -> Void

@objc(JSMediaBrowserViewControllerTransitioningStyle)
public enum TransitioningStyle: Int {
    case zoom
    case fade
}

@objc(JSMediaBrowserViewController)
open class MediaBrowserViewController: UIViewController {
    
    @objc open lazy var browserView: MediaBrowserView = {
        let browserView = MediaBrowserView()
        return browserView
    }()
    
    @objc open lazy var transitioningAnimator: UIViewControllerAnimatedTransitioning = {
        let animator = TransitionAnimator()
        animator.delegate = self
        return animator
    }()
    
    @objc open var enteringStyle: TransitioningStyle = .zoom {
        didSet {
            if let animator = transitioningAnimator as? TransitionAnimator {
                animator.enteringStyle = enteringStyle
            }
        }
    }
    @objc open var exitingStyle: TransitioningStyle = .zoom {
        didSet {
            if let animator = transitioningAnimator as? TransitionAnimator {
                animator.exitingStyle = exitingStyle
            }
        }
    }
    
    @objc open var sourceItems: Array<SourceProtocol> = [] {
        didSet {
            var loaderItems: Array<LoaderProtocol> = Array()
            self.sourceItems.forEach({ (item) in
                #if BUSINESS_IMAGE
                if let _ = item as? ImageSourceProtocol {
                    let loader: ImageLoaderEntity = ImageLoaderEntity()
                    loader.sourceItem = item
                    loader.webImageMediator = self.webImageMediatorBlock?(self, item)
                    loaderItems.append(loader)
                }
                #endif
                #if BUSINESS_VIDEO
                if let _ = item as? VideoSourceProtocol {
                    let loader: VideoLoaderEntity = VideoLoaderEntity()
                    loader.sourceItem = item
                    loaderItems.append(loader)
                }
                #endif
            })
            self.loaderItems = loaderItems
            
            for toolView in self.toolViews {
                toolView.sourceItemsDidChange?(in: self)
            }
        }
    }
    
    @objc open var dismissWhenSlidingDistance: CGFloat = 60
    
    #if BUSINESS_IMAGE
    @objc open var imageViewForZoomViewBlock: BuildImageViewForZoomViewBlock?
    @objc open var livePhotoViewForZoomViewBlock: BuildLivePhotoViewForZoomViewBlock?
    @objc open var webImageMediatorBlock: BuildWebImageMediatorBlock?
    #endif
    @objc open var toolViewsBlock: BuildToolViewsBlock?
    @objc open var cellForItemAtPageBlock: BuildCellBlock?
    @objc open var configureCellBlock: ConfigureCellBlock?
    @objc open var willDisplayEmptyViewBlock: DisplayEmptyViewBlock?
    @objc open var onLongPressBlock: LongPressBlock?
    @objc open var viewDidLoadBlock: ((MediaBrowserViewController) -> Void)?
    @objc open var viewWillAppearBlock: ((MediaBrowserViewController) -> Void)?
    @objc open var viewDidDisappearBlock: ((MediaBrowserViewController) -> Void)?
    
    private var loaderItems: Array<LoaderProtocol> = []
    private static let imageCellIdentifier: String = "ImageCellIdentifier"
    private static let videoCellIdentifier: String = "VideoCellIdentifier"
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        if #available(iOS 11.0, *) {
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
}

extension MediaBrowserViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
        /// 注册Cell
        #if BUSINESS_IMAGE
        self.registerClass(ImageCell.self, forCellWithReuseIdentifier: MediaBrowserViewController.imageCellIdentifier)
        #endif
        #if BUSINESS_VIDEO
        self.registerClass(VideoCell.self, forCellWithReuseIdentifier: MediaBrowserViewController.videoCellIdentifier)
        /// 注册完cell再加代理, 防止崩溃
        self.browserView.delegate = self
        self.browserView.dataSource = self
        self.browserView.gestureDelegate = self
        self.view.addSubview(self.browserView)
        #endif
        /// 工具视图
        let toolViews: Array<UIView & ToolViewProtocol> = self.toolViewsBlock?(self) ?? []
        for toolView in toolViews {
            self.view.addSubview(toolView)
            toolView.didAddToSuperview(in: self)
        }
        self.viewDidLoadBlock?(self)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.browserView.js_frameApplyTransform = self.view.bounds
        
        for toolView in self.toolViews {
            toolView.didLayoutSubviews?(in: self)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 外部可能设置导航栏, 这里需要隐藏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let sourceView = self.transitionSourceView, !sourceView.isHidden {
            sourceView.isHidden = true
        }
        
        self.browserView.reloadData()
        self.browserView.collectionView.layoutIfNeeded()
        
        self.viewWillAppearBlock?(self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        /// 修复动态图或视频可能不播放的问题
        if let cell = self.browserView.currentPageCell {
            self.mediaBrowserView(self.browserView, willDisplay: cell, forItemAt: self.browserView.currentPage)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let sourceView = self.transitionSourceView, sourceView.isHidden {
            sourceView.isHidden = false
        }
        
        self.viewDidDisappearBlock?(self)
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    open override var shouldAutorotate: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
}

extension MediaBrowserViewController {
    
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
    
    @objc open func toolViewForClass(_ viewClass: UIView.Type) -> UIView? {
        for view in self.toolViews {
            if view.isKind(of: viewClass) {
                return view
            }
        }
        return nil
    }
    
    @objc(showFromViewController:animated:completion:)
    open func show(from sender: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
        self.transitioningDelegate = self
        sender.present(self, animated: animated, completion: completion)
    }
    
    @objc open func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(animated: animated, completion: completion)
    }
    
    @objc public func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        self.browserView.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    @objc(dequeueReusableCell:atIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        return self.browserView.dequeueReusableCell(withReuseIdentifier: identifier, at: index)
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    public func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int {
        return self.loaderItems.count
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt index: Int) -> UICollectionViewCell {
        var cell: UICollectionViewCell? = self.cellForItemAtPageBlock?(self, index)
        let loaderItem: LoaderProtocol = self.loaderItems[index]
        #if BUSINESS_IMAGE
        if cell == nil, let _ = loaderItem as? ImageLoaderProtocol {
            cell = self.dequeueReusableCell(withReuseIdentifier: MediaBrowserViewController.imageCellIdentifier, at: index)
        }
        #endif
        #if BUSINESS_VIDEO
        if cell == nil, let _ = loaderItem as? VideoLoaderProtocol {
            cell = self.dequeueReusableCell(withReuseIdentifier: MediaBrowserViewController.videoCellIdentifier, at: index)
        }
        #endif
        if let basisCell = cell as? BasisCell {
            self.configureCell(basisCell, at: index)
        }
        self.configureCellBlock?(self, cell!, index)
        return cell!
    }
    
    private func configureCell(_ cell: BasisCell, at index: Int) -> Void {
        cell.onEmptyPressAction = { [weak self] (cell: UICollectionViewCell) in
            if let index: Int = self?.browserView.index(for: cell), index != NSNotFound {
                self?.browserView.reloadPages(at: [index])
            }
        }
        cell.willDisplayEmptyViewBlock = { [weak self] (cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            if let strongSelf = self {
                strongSelf.willDisplayEmptyViewBlock?(strongSelf, cell, emptyView, error)
            }
        }
        #if BUSINESS_IMAGE
        if let imageCell = cell as? ImageCell {
            self.configureImageCell(imageCell, at: index)
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = cell as? VideoCell {
            self.configureVideoCell(videoCell, at: index)
        }
        #endif
    }
    
    #if BUSINESS_IMAGE
    private func configureImageCell(_ cell: ImageCell, at index: Int) -> Void {
        /// 先设置代理
        cell.zoomImageView.delegate = self
        /// 当dismissingGesture失败时才会去响应scrollView的手势
        cell.zoomImageView.require(toFail: self.browserView.dismissingGesture)
        if let loaderItem: ImageLoaderProtocol = loaderItems[index] as? ImageLoaderProtocol {
            let imageView: UIImageView = cell.zoomImageView.imageView
            loaderItem.cancelRequest(for: imageView)
            loaderItem.request(for: imageView) { [weak cell](loader: LoaderProtocol, object: Any?, data: Data?) in
                let image: UIImage? = object as? UIImage
                cell?.zoomImageView.image = image
            } downloadProgress: { [weak cell](loader: LoaderProtocol, progress: Progress) in
                cell?.setProgress(progress)
            } completed: { [weak cell](loader: LoaderProtocol, object: Any?, data: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
                cell?.setError(error, cancelled: cancelled, finished: finished)
                let image: UIImage? = object as? UIImage
                cell?.zoomImageView.image = image
                if image != nil && error == nil {
                    /// 解决网络图片下载完成后不播放的问题
                    cell?.zoomImageView.startAnimating()
                }
            }
        }
    }
    #endif
    
    #if BUSINESS_VIDEO
    private func configureVideoCell(_ cell: VideoCell, at index: Int) -> Void {
        if  let sourceItem: VideoSourceProtocol = self.loaderItems[index].sourceItem as? VideoSourceProtocol {
            cell.videoPlayerView.thumbImage = sourceItem.thumbImage
            /// 前后url不相同时需要释放之前的player, 否则会先显示之前的画面, 再显示当前的
            if cell.videoPlayerView.url != sourceItem.videoUrl {
                cell.videoPlayerView.releasePlayer()
            }
            cell.videoPlayerView.url = sourceItem.videoUrl
        }
    }
    #endif
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt index: Int) {
        #if BUSINESS_IMAGE
        if let imageCell = cell as? ImageCell, let loaderItem: ImageLoaderProtocol = self.loaderItems[index] as? ImageLoaderProtocol {
            if loaderItem.isFinished {
                imageCell.zoomImageView.startAnimating()
            }
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = cell as? VideoCell {
            videoCell.videoPlayerView.play()
        }
        #endif
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int) {
        #if BUSINESS_IMAGE
        if let imageCell = cell as? ImageCell {
            imageCell.zoomImageView.stopAnimating()
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = cell as? VideoCell {
            videoCell.videoPlayerView.reset()
        }
        #endif
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, willScrollHalf fromIndex: Int, toIndex: Int) {
        if let sourceItem = self.loaderItems[fromIndex].sourceItem {
            sourceItem.sourceView?.isHidden = false
        }
        if let sourceItem = self.loaderItems[toIndex].sourceItem {
            sourceItem.sourceView?.isHidden = true
        }
        for toolView in self.toolViews {
            toolView.willScrollHalf?(fromIndex: fromIndex, toIndex: toIndex, in: self)
        }
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int) {
        for toolView in self.toolViews {
            toolView.didScrollTo?(index: index, in: self)
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewGestureDelegate {
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        self.hide()
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        #if BUSINESS_IMAGE
        if let imageCell = browserView.currentPageCell as? ImageCell {
            let zoomImageView = imageCell.zoomImageView
            if zoomImageView.zoomScale >= zoomImageView.maximumZoomScale {
                zoomImageView.setZoom(scale: zoomImageView.finalMinimumZoomScale)
            } else {
                let gesturePoint: CGPoint = gestureRecognizer.location(in: gestureRecognizer.view)
                zoomImageView.zoom(to: gesturePoint)
            }
        }
        #endif
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer) {
        self.onLongPressBlock?(self)
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, dismissingShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        #if BUSINESS_IMAGE
        guard let imageCell = browserView.currentPageCell as? ImageCell else {
            return true
        }
        let zoomImageView: ZoomImageView = imageCell.zoomImageView
        let scrollView = zoomImageView.scrollView
        let velocity: CGPoint = gestureRecognizer.velocity(in: gestureRecognizer.view)
        if velocity.y > 0 {
            let minY: CGFloat = ceil(zoomImageView.minContentOffset.y)
            /// 手势向下
            return scrollView.contentOffset.y <= minY && !(scrollView.isDragging || scrollView.isDecelerating)
        } else {
            let maxY: CGFloat = floor(zoomImageView.maxContentOffset.y)
            /// 手势向上
            return scrollView.contentOffset.y >= maxY && !(scrollView.isDragging || scrollView.isDecelerating)
        }
        #else
        return true
        #endif
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, dismissingChanged gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat) {
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            var alpha: CGFloat = 1
            let height: NSNumber = NSNumber(value: Float(browserView.bounds.height / 2))
            if verticalDistance > 0 {
                alpha = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.2], extrapolateLeft: .clamp, extrapolateRight: .clamp)
            }
            for toolView in self.toolViews {
                toolView.alpha = alpha
            }
            break
        case .ended:
            if verticalDistance > self.dismissWhenSlidingDistance {
                self.hide()
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

#if BUSINESS_IMAGE
extension MediaBrowserViewController: ZoomImageViewDelegate {
    
    @objc public func zoomImageViewLazyBuildImageView(_ zoomImageView: ZoomImageView) -> UIImageView {
        let imageView: UIImageView = self.imageViewForZoomViewBlock?(self, zoomImageView) ?? UIImageView()
        return imageView
    }
    
    @objc public func zoomImageViewLazyBuildLivePhotoView(_ zoomImageView: ZoomImageView) -> PHLivePhotoView {
        let livePhotoView: PHLivePhotoView = self.livePhotoViewForZoomViewBlock?(self, zoomImageView) ?? PHLivePhotoView()
        return livePhotoView
    }
    
}
#endif

extension MediaBrowserViewController: UIViewControllerTransitioningDelegate, TransitionAnimatorDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animator = transitioningAnimator as? TransitionAnimator {
            animator.animatorType = .presenting
        }
        return self.transitioningAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animator = transitioningAnimator as? TransitionAnimator {
            animator.animatorType = .dismiss
        }
        return self.transitioningAnimator
    }
    
    public var transitionSourceRect: CGRect {
        let sourceItem = self.sourceItems[self.browserView.currentPage]
        return sourceItem.sourceRect
    }
    
    public var transitionSourceView: UIView? {
        let sourceItem = self.sourceItems[self.browserView.currentPage]
        return sourceItem.sourceView
    }
    
    public var transitionCornerRadius: CGFloat {
        let sourceItem = self.sourceItems[self.browserView.currentPage]
        if sourceItem.sourceCornerRadius > 0 {
            return sourceItem.sourceCornerRadius
        } else {
            return sourceItem.sourceView?.layer.cornerRadius ?? 0
        }
    }
    
    public var transitionThumbImage: UIImage? {
        let currentPage = self.browserView.currentPage
        #if BUSINESS_IMAGE
        if let sourceItem = self.sourceItems[currentPage] as? ImageSourceProtocol {
            return (sourceItem.image != nil) ? sourceItem.image : sourceItem.thumbImage
        }
        #endif
        #if BUSINESS_VIDEO
        if let sourceItem = self.sourceItems[currentPage] as? VideoSourceProtocol {
            return sourceItem.thumbImage
        }
        #endif
        return nil
    }
    
    public var transitionAnimatorViews: Array<UIView>? {
        var animatorViews: [UIView] = self.toolViews
        if let dimmingView = self.browserView.dimmingView {
            animatorViews.append(dimmingView)
        }
        return animatorViews
    }
    
    public var transitionTargetView: UIView? {
        if let cell = self.browserView.currentPageCell {
            return cell
        }
        return nil
    }
    
    public var transitionTargetFrame: CGRect {
        #if BUSINESS_IMAGE
        if let imageCell = self.browserView.currentPageCell as? ImageCell {
            return imageCell.zoomImageView.contentViewFrame
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = self.browserView.currentPageCell as? VideoCell {
            return videoCell.videoPlayerView.contentViewFrame
        }
        #endif
        return CGRect.zero
    }
    
}
