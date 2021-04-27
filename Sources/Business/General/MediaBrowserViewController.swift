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
    
    @objc open var browserView: MediaBrowserView?
    @objc open var sourceItems: Array<SourceProtocol>? {
        didSet {
            var array: Array<LoaderProtocol> = Array()
            sourceItems?.forEach({ (item) in
                #if BUSINESS_IMAGE
                if let _ = item as? ImageSourceProtocol {
                    let loader: ImageLoaderEntity = ImageLoaderEntity()
                    loader.sourceItem = item
                    if let block = self.webImageMediatorBlock {
                        loader.webImageMediator = block(self, item)
                    }
                    array.append(loader)
                }
                #endif
                #if BUSINESS_VIDEO
                if let _ = item as? VideoSourceProtocol {
                    let loader: VideoLoaderEntity = VideoLoaderEntity()
                    loader.sourceItem = item
                    array.append(loader)
                }
                #endif
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
    
    private var loaderItems: Array<LoaderProtocol>?
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
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        
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
        #if BUSINESS_IMAGE
        self.registerClass(ImageCell.self, forCellWithReuseIdentifier: MediaBrowserViewController.imageCellIdentifier)
        #endif
        #if BUSINESS_VIDEO
        self.registerClass(VideoCell.self, forCellWithReuseIdentifier: MediaBrowserViewController.videoCellIdentifier)
        #endif
        /// 工具视图
        if let block = self.toolViewsBlock {
            let toolViews: Array<UIView & ToolViewProtocol> = block(self)
            for toolView in toolViews {
                self.view.addSubview(toolView)
                toolView.didAddToSuperview(in: self)
            }
        }
        if let block = self.viewDidLoadBlock {
            block(self)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds: CGRect = self.view.bounds
        self.browserView?.js_frameApplyTransform = bounds
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
        if let block = self.viewWillAppearBlock {
            block(self)
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
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let block = self.viewDidDisappearBlock {
            block(self)
        }
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
        sender.present(self, animated: animated, completion: completion)
    }
    
    @objc open func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(animated: animated, completion: completion)
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
        if let block = self.cellForItemAtPageBlock {
            cell = block(self, index)
        }
        if let loaderItem: LoaderProtocol = loaderItems?[index] {
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
        }
        if let block = self.configureCellBlock {
            block(self, cell, index)
        }
        return cell
    }
    
    private func configureCell(_ cell: BasisCell, at index: Int) -> Void {
        cell.onEmptyPressAction = { [weak self] (cell: UICollectionViewCell) in
            if let index: Int = self?.browserView?.index(for: cell), index != NSNotFound {
                self?.browserView?.reloadPages(at: [index])
            }
        }
        cell.willDisplayEmptyViewBlock = { [weak self] (cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            if let block = self?.willDisplayEmptyViewBlock, let strongSelf = self {
                block(strongSelf, cell, emptyView, error)
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
        cell.zoomImageView?.delegate = self
        if let loaderItem: ImageLoaderProtocol = loaderItems?[index] as? ImageLoaderProtocol {
            loaderItem.cancelRequest(for: cell.zoomImageView?.imageView)
            loaderItem.request(for: cell.zoomImageView?.imageView) { [weak cell](loader: LoaderProtocol, object: Any?, data: Data?) in
                let image: UIImage? = object as? UIImage
                cell?.zoomImageView?.image = image
            } downloadProgress: { [weak cell](loader: LoaderProtocol, progress: Progress?) in
                cell?.setProgress(progress)
            } completed: { [weak cell](loader: LoaderProtocol, object: Any?, data: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
                cell?.setError(error, cancelled: cancelled, finished: finished)
                let image: UIImage? = object as? UIImage
                cell?.zoomImageView?.image = image
            }
        }
    }
    #endif
    
    #if BUSINESS_VIDEO
    private func configureVideoCell(_ cell: VideoCell, at index: Int) -> Void {
        if  let sourceItem: VideoSourceProtocol = self.loaderItems?[index].sourceItem as? VideoSourceProtocol {
            cell.videoPlayerView?.thumbImage = sourceItem.thumbImage
            /// 前后url不相同时需要释放之前的player, 否则会先显示之前的画面, 再显示当前的
            if cell.videoPlayerView?.url != sourceItem.videoUrl {
                cell.videoPlayerView?.releasePlayer()
            }
            cell.videoPlayerView?.url = sourceItem.videoUrl
        }
    }
    #endif
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt index: Int) {
        #if BUSINESS_IMAGE
        if let imageCell = cell as? ImageCell {
            imageCell.zoomImageView?.startAnimating()
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = cell as? VideoCell {
            videoCell.videoPlayerView?.play()
        }
        #endif
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int) {
        #if BUSINESS_IMAGE
        if let imageCell = cell as? ImageCell {
            imageCell.zoomImageView?.stopAnimating()
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = cell as? VideoCell {
            videoCell.videoPlayerView?.reset()
        }
        #endif
    }
    
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
        self.hide()
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        #if BUSINESS_IMAGE
        if let imageCell = browserView.currentPageCell as? ImageCell, let zoomImageView = imageCell.zoomImageView {
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
        if let block = self.onLongPressBlock {
            block(self)
        }
    }
    
    @objc public func mediaBrowserView(_ browserView: MediaBrowserView, dismissing gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat) {
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
            if verticalDistance > browserView.bounds.height / 4 {
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
        var imageView: UIImageView
        if let block = self.imageViewForZoomViewBlock {
            imageView = block(self, zoomImageView)
        } else {
            imageView = UIImageView()
        }
        return imageView
    }
    
    @objc public func zoomImageViewLazyBuildLivePhotoView(_ zoomImageView: ZoomImageView) -> PHLivePhotoView {
        var livePhotoView: PHLivePhotoView
        if let block = self.livePhotoViewForZoomViewBlock {
            livePhotoView = block(self, zoomImageView)
        } else {
            livePhotoView = PHLivePhotoView()
        }
        return livePhotoView
    }
    
}
#endif

extension MediaBrowserViewController: UIViewControllerTransitioningDelegate, TransitionAnimatorDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitioningAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitioningAnimator
    }
    
    public var transitionSourceRect: CGRect {
        if let sourceItem = self.sourceItems?[browserView?.currentPage ?? 0] {
            return sourceItem.sourceRect
        }
        return CGRect.zero
    }
    
    public var transitionSourceView: UIView? {
        if let sourceItem = self.sourceItems?[browserView?.currentPage ?? 0] {
            return sourceItem.sourceView
        }
        return nil
    }
    
    public var transitionCornerRadius: CGFloat {
        if let sourceItem = self.sourceItems?[browserView?.currentPage ?? 0] {
            if sourceItem.sourceCornerRadius > 0 {
                return sourceItem.sourceCornerRadius
            } else {
                return sourceItem.sourceView?.layer.cornerRadius ?? 0
            }
        }
        return 0
    }
    
    public var transitionThumbImage: UIImage? {
        let currentPage = self.browserView?.currentPage ?? 0
        #if BUSINESS_IMAGE
        if let sourceItem = self.sourceItems?[currentPage] as? ImageSourceProtocol {
            return (sourceItem.image != nil) ? sourceItem.image : sourceItem.thumbImage
        }
        #endif
        #if BUSINESS_VIDEO
        if let sourceItem = self.sourceItems?[currentPage] as? VideoSourceProtocol {
            return sourceItem.thumbImage
        }
        #endif
        return nil
    }
    
    public var transitionAnimatorViews: Array<UIView>? {
        var animatorViews: [UIView] = self.toolViews
        if let dimmingView = self.browserView?.dimmingView {
            animatorViews.append(dimmingView)
        }
        return animatorViews
    }
    
    public var transitionTargetView: UIView? {
        if let cell = self.browserView?.currentPageCell {
            return cell
        }
        return nil
    }
    
    public var transitionTargetFrame: CGRect {
        #if BUSINESS_IMAGE
        if let imageCell = self.browserView?.currentPageCell as? ImageCell {
            return imageCell.zoomImageView?.contentViewFrame ?? CGRect.zero
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = self.browserView?.currentPageCell as? VideoCell {
            return videoCell.videoPlayerView?.contentViewFrame ?? CGRect.zero
        }
        #endif
        return CGRect.zero
    }
    
}
