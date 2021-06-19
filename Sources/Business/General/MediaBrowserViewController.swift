//
//  MediaBrowserViewController.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/11.
//

import UIKit
import JSCoreKit
import PhotosUI

public enum TransitioningStyle: Int {
    case zoom
    case fade
}

open class MediaBrowserViewController: UIViewController {
    
    open lazy var browserView: MediaBrowserView = {
        let browserView = MediaBrowserView()
        return browserView
    }()
    
    open lazy var transitioningAnimator: UIViewControllerAnimatedTransitioning = {
        let animator = TransitionAnimator()
        animator.delegate = self
        return animator
    }()
    
    open var enteringStyle: TransitioningStyle = .zoom {
        didSet {
            if let animator = transitioningAnimator as? TransitionAnimator {
                animator.enteringStyle = enteringStyle
            }
        }
    }
    open var exitingStyle: TransitioningStyle = .zoom {
        didSet {
            if let animator = transitioningAnimator as? TransitionAnimator {
                animator.exitingStyle = exitingStyle
            }
        }
    }
    
    open var sourceItems: [SourceProtocol] = [] {
        didSet {
            var loaderItems: [LoaderProtocol] = []
            self.sourceItems.forEach({ (item) in
                #if BUSINESS_IMAGE
                if let _ = item as? ImageSourceProtocol {
                    let loader: ImageLoaderEntity = ImageLoaderEntity()
                    loader.sourceItem = item
                    loader.webImageMediator = self.webImageMediator
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
            
            self.toggleTotalUnitPageDidChange()
        }
    }
    
    open private(set) var loaderItems: [LoaderProtocol] = []
    
    open weak var sourceViewDelegate: MediaBrowserViewControllerSourceViewDelegate?
    
    open var additionalViews: [UIView & AdditionalViewProtocol] = [] {
        didSet {
            for additionalView in oldValue {
                additionalView.removeFromSuperview()
            }
            self.togglePrepareAdditionalViews()
        }
    }
    
    #if BUSINESS_IMAGE
    open var webImageMediator: WebImageMediatorProtocol?
    open var imageViewForZoomView: ((MediaBrowserViewController, ZoomImageView) -> UIImageView)?
    open var livePhotoViewForZoomView: ((MediaBrowserViewController, ZoomImageView) -> PHLivePhotoView)?
    #endif
    
    open var cellForItemAtPage: ((MediaBrowserViewController, Int) -> UICollectionViewCell?)?
    open var configureCell: ((MediaBrowserViewController, UICollectionViewCell, Int) -> Void)?
    open var willDisplayEmptyView: ((MediaBrowserViewController, UICollectionViewCell, EmptyView, NSError) -> Void)?
    open var onLongPress: ((MediaBrowserViewController) -> Void)?
    
    open var currentPage: Int {
        set {
            self.browserView.currentPage = newValue
        }
        get {
            return self.browserView.currentPage
        }
    }
    
    open var totalUnitPage: Int {
        return self.browserView.totalUnitPage
    }
    
    open var currentPageCell: UICollectionViewCell? {
        return self.browserView.currentPageCell
    }
    
    open var dismissWhenSlidingDistance: CGFloat = 60
    
    private static let imageCellIdentifier: String = "ImageCellIdentifier"
    private static let videoCellIdentifier: String = "VideoCellIdentifier"
    fileprivate var hasAlreadyViewWillAppear: Bool = false
    
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
        #endif
        /// 注册完cell再加代理, 防止崩溃
        self.browserView.delegate = self
        self.browserView.dataSource = self
        self.browserView.gestureDelegate = self
        self.view.addSubview(self.browserView)
        
        self.togglePrepareAdditionalViews()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.browserView.js_frameApplyTransform = self.view.bounds
        
        for additionalView in self.additionalViews {
            additionalView.layout(in: self)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 外部可能设置导航栏, 这里需要隐藏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let sourceView = self.transitionSourceView, !sourceView.isHidden {
            sourceView.isHidden = true
        }
        
        if !self.hasAlreadyViewWillAppear {
            self.hasAlreadyViewWillAppear = true
            /// 提前reloadData, 可以拿到currentPageCell
            self.browserView.reloadData()
            self.browserView.collectionView.layoutIfNeeded()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        /// 修复动态图或视频可能不播放的问题
        if let cell = self.currentPageCell {
            self.mediaBrowserView(self.browserView, willDisplay: cell, forItemAt: self.currentPage)
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
    
    open func show(from sender: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
        self.transitioningDelegate = self
        sender.present(self, animated: animated, completion: completion)
    }
    
    open func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(animated: animated, completion: completion)
    }
    
    public func registerClass(_ cellClass: AnyClass, forCellWithReuseIdentifier identifier: String) -> Void {
        self.browserView.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        return self.browserView.dequeueReusableCell(withReuseIdentifier: identifier, at: index)
    }
    
    open func setCurrentPage(_ index: Int, animated: Bool = true) -> Void {
        self.browserView.setCurrentPage(index, animated: animated)
    }
    
}

extension MediaBrowserViewController {
    
    private func togglePrepareAdditionalViews() {
        if !self.isViewLoaded {
            return
        }
        for additionalView in self.additionalViews {
            additionalView.removeFromSuperview()
            self.view.addSubview(additionalView)
            additionalView.prepare(in: self)
        }
        self.toggleTotalUnitPageDidChange()
    }
    
    private func toggleTotalUnitPageDidChange() {
        if !self.isViewLoaded {
            return
        }
        for additionalView in self.additionalViews {
            additionalView.totalUnitPageDidChange(self.totalUnitPage, in: self)
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    public func numberOfPagesInMediaBrowserView(_ browserView: MediaBrowserView) -> Int {
        return self.loaderItems.count
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt index: Int) -> UICollectionViewCell {
        var cell: UICollectionViewCell? = self.cellForItemAtPage?(self, index)
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
        self.configureCell?(self, cell!, index)
        return cell!
    }
    
    private func configureCell(_ cell: BasisCell, at index: Int) -> Void {
        cell.onEmptyPressAction = { [weak self] (cell: UICollectionViewCell) in
            if let index: Int = self?.browserView.index(for: cell), index != NSNotFound {
                self?.browserView.reloadPages(at: [index])
            }
        }
        cell.willDisplayEmptyView = { [weak self] (cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            if let strongSelf = self {
                self?.willDisplayEmptyView?(strongSelf, cell, emptyView, error)
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
        if let imageCell = cell as? ImageCell,
           let loaderItem: ImageLoaderProtocol = self.loaderItems[index] as? ImageLoaderProtocol {
            if loaderItem.isFinished && !imageCell.zoomImageView.isAnimating {
                imageCell.zoomImageView.startAnimating()
            }
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = cell as? VideoCell {
            let status: Stauts = videoCell.videoPlayerView.status
            if status == .ready || status == .paused {
                videoCell.videoPlayerView.play()
            }
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
        if let sourceView = self.sourceViewDelegate?.sourceViewForPageAtIndex(fromIndex) {
            sourceView.isHidden = false
        }
        if let sourceView = self.sourceViewDelegate?.sourceViewForPageAtIndex(toIndex) {
            sourceView.isHidden = true
        }
        for additionalView in self.additionalViews {
            additionalView.willScrollHalf(fromIndex: fromIndex, toIndex: toIndex, in: self)
        }
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, didScrollTo index: Int) {
        for additionalView in self.additionalViews {
            additionalView.didScroll(to: index, in: self)
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewGestureDelegate {
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        self.hide()
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        #if BUSINESS_IMAGE
        if let imageCell = self.currentPageCell as? ImageCell {
            let zoomImageView = imageCell.zoomImageView
            let zoomScale = zoomImageView.maximumZoomScale
            if zoomImageView.zoomScale >= zoomScale {
                zoomImageView.setZoom(scale: zoomImageView.minimumZoomScale)
            } else {
                let gesturePoint: CGPoint = gestureRecognizer.location(in: zoomImageView.contentView)
                zoomImageView.zoom(to: gesturePoint, scale: zoomScale)
            }
        }
        #endif
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer) {
        self.onLongPress?(self)
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, dismissingShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        #if BUSINESS_IMAGE
        guard let imageCell = self.currentPageCell as? ImageCell else {
            return true
        }
        let zoomImageView: ZoomImageView = imageCell.zoomImageView
        let scrollView = zoomImageView.scrollView
        let velocity: CGPoint = gestureRecognizer.velocity(in: gestureRecognizer.view)
        let minY: CGFloat = ceil(zoomImageView.minContentOffset.y)
        let maxY: CGFloat = floor(zoomImageView.maxContentOffset.y)
        /// 垂直触摸滑动
        if abs(velocity.x) <= abs(velocity.y) {
            if velocity.y > 0 {
                /// 手势向下
                return scrollView.contentOffset.y <= minY && !(scrollView.isDragging || scrollView.isDecelerating)
            } else {
                /// 手势向上
                return scrollView.contentOffset.y >= maxY && !(scrollView.isDragging || scrollView.isDecelerating)
            }
        } else {
            return false
        }
        #else
        return true
        #endif
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, dismissingChanged gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat) {
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            var alpha: CGFloat = 1
            let height: NSNumber = NSNumber(value: Float(browserView.bounds.height / 2))
            if verticalDistance > 0 {
                alpha = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.2], extrapolateLeft: .clamp, extrapolateRight: .clamp)
            }
            for additionalView in self.additionalViews {
                additionalView.alpha = alpha
            }
            break
        case .ended:
            if verticalDistance > self.dismissWhenSlidingDistance {
                self.hide()
            } else {
                browserView.resetDismissingGesture(withAnimations: { () -> Void in
                    for additionalView in self.additionalViews {
                        additionalView.alpha = 1.0
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
    
    public func zoomImageViewLazyBuildImageView(_ zoomImageView: ZoomImageView) -> UIImageView {
        return self.imageViewForZoomView?(self, zoomImageView) ?? UIImageView()
    }
    
    public func zoomImageViewLazyBuildLivePhotoView(_ zoomImageView: ZoomImageView) -> PHLivePhotoView {
        return self.livePhotoViewForZoomView?(self, zoomImageView) ?? PHLivePhotoView()
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
        let sourceItem = self.loaderItems[self.currentPage].sourceItem
        return sourceItem?.sourceRect ?? CGRect.zero
    }
    
    public var transitionSourceView: UIView? {
        return self.sourceViewDelegate?.sourceViewForPageAtIndex(self.currentPage)
    }
    
    public var transitionCornerRadius: CGFloat {
        return self.sourceViewDelegate?.sourceViewCornerRadiusForPageAtIndex(self.currentPage) ?? 0
    }
    
    public var transitionThumbImage: UIImage? {
        let currentPage = self.currentPage
        #if BUSINESS_IMAGE
        if let sourceItem = self.loaderItems[currentPage].sourceItem as? ImageSourceProtocol {
            return (sourceItem.image != nil) ? sourceItem.image : sourceItem.thumbImage
        }
        #endif
        #if BUSINESS_VIDEO
        if let sourceItem = self.loaderItems[currentPage].sourceItem as? VideoSourceProtocol {
            return sourceItem.thumbImage
        }
        #endif
        return nil
    }
    
    public var transitionAnimatorViews: [UIView]? {
        var animatorViews: [UIView] = self.additionalViews
        if let dimmingView = self.browserView.dimmingView {
            animatorViews.append(dimmingView)
        }
        return animatorViews
    }
    
    public var transitionTargetView: UIView? {
        if let cell = self.currentPageCell {
            return cell
        }
        return nil
    }
    
    public var transitionTargetFrame: CGRect {
        #if BUSINESS_IMAGE
        if let imageCell = self.currentPageCell as? ImageCell {
            return imageCell.zoomImageView.contentViewFrame
        }
        #endif
        #if BUSINESS_VIDEO
        if let videoCell = self.currentPageCell as? VideoCell {
            return videoCell.videoPlayerView.contentViewFrame
        }
        #endif
        return CGRect.zero
    }
    
}
