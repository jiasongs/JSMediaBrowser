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
    
    open var enteringStyle: TransitioningStyle = .zoom {
        didSet {
            self.transitionAnimator.enteringStyle = enteringStyle
        }
    }
    
    open var exitingStyle: TransitioningStyle = .zoom {
        didSet {
            self.transitionAnimator.exitingStyle = exitingStyle
        }
    }
    
    open var sourceItems: [SourceProtocol] = [] {
        didSet {
            guard self.isNeedsReloadData && self.isViewLoaded else {
                return
            }
            self.mediaBrowserView.reloadData()
        }
    }
    
    open var zoomImageViewModifier: ZoomImageViewModifier?
    open var webImageMediator: WebImageMediator?
    
    open var sourceViewForPageAtIndex: ((MediaBrowserViewController, Int) -> UIView?)?
    open var willDisplayEmptyView: ((MediaBrowserViewController, UICollectionViewCell, EmptyView, NSError) -> Void)?
    open var onLongPress: ((MediaBrowserViewController) -> Void)?
    
    open var currentPage: Int {
        set {
            self.mediaBrowserView.currentPage = newValue
        }
        get {
            return self.mediaBrowserView.currentPage
        }
    }
    
    open var dismissWhenSlidingDistance: CGFloat = 60
    
    open private(set) weak var presentedFromViewController: UIViewController?
    
    fileprivate lazy var mediaBrowserView: MediaBrowserView = {
        let mediaBrowserView = MediaBrowserView()
        return mediaBrowserView
    }()
    
    fileprivate lazy var transitionAnimator: TransitionAnimator = {
        let animator = TransitionAnimator()
        animator.delegate = self
        return animator
    }()
    
    fileprivate lazy var transitionInteractiver: TransitionInteractiver = {
        let interactiver = TransitionInteractiver()
        return interactiver
    }()
    
    fileprivate var gestureBeganLocation: CGPoint = CGPoint.zero
    
    fileprivate var isNeedsReloadData: Bool = true
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() {
        self.extendedLayoutIncludesOpaqueBars = true
        self.accessibilityViewIsModal = true
    }
    
    deinit {
        print("mediaBrowser 释放")
    }
    
}

extension MediaBrowserViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
        self.view.addSubview(self.mediaBrowserView)
        
        self.mediaBrowserView.dataSource = self
        self.mediaBrowserView.delegate = self
        self.mediaBrowserView.gestureDelegate = self
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mediaBrowserView.js_frameApplyTransform = self.view.bounds
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 外部可能设置导航栏, 这里需要隐藏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let sourceView = self.transitionSourceView, !sourceView.isHidden {
            sourceView.isHidden = true
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let sourceView = self.transitionSourceView, sourceView.isHidden {
            sourceView.isHidden = false
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let sourceView = self.transitionSourceView, sourceView.isHidden {
            sourceView.isHidden = false
        }
        coordinator.animateAlongsideTransition(in: self.view, animation: nil) { context in
            if let sourceView = self.transitionSourceView, !sourceView.isHidden {
                sourceView.isHidden = true
            }
        }
    }
    
}

extension MediaBrowserViewController {
    
    public var totalUnitPage: Int {
        return self.mediaBrowserView.totalUnitPage
    }
    
    public var currentPageCell: UICollectionViewCell? {
        return self.mediaBrowserView.currentPageCell
    }
    
    public func setCurrentPage(_ index: Int, animated: Bool = true) {
        self.mediaBrowserView.setCurrentPage(index, animated: animated)
    }
    
    public func show(from sender: UIViewController,
                     navigationController: UINavigationController? = nil,
                     animated: Bool = true,
                     completion: (() -> Void)? = nil) {
        self.presentedFromViewController = sender
        
        let viewController = navigationController ?? self
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.transitioningDelegate = self
        var senderViewController = sender
        if let tabBarController = sender.tabBarController, (!tabBarController.tabBar.isHidden && !sender.hidesBottomBarWhenPushed) {
            senderViewController = tabBarController
        }
        senderViewController.present(viewController, animated: animated, completion: completion)
    }
    
    public func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(animated: animated, completion: completion)
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    @objc open func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int {
        return self.sourceItems.count
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, cellForPageAt index: Int) -> UICollectionViewCell {
        var cell: BasisCell? = nil
        let sourceItem = self.sourceItems[index]
        if let _ = sourceItem as? ImageSourceProtocol {
            cell = mediaBrowserView.dequeueReusableCell(ImageCell.self, at: index)
        } else if let _ = sourceItem as? VideoSourceProtocol {
            cell = mediaBrowserView.dequeueReusableCell(VideoCell.self, at: index)
        }
        guard let cell = cell else {
            return mediaBrowserView.dequeueReusableCell(UICollectionViewCell.self, at: index)
        }
        self.configureCell(cell, at: index)
        return cell
    }
    
    fileprivate func configureCell(_ cell: BasisCell, at index: Int) {
        cell.onPressEmpty = { [weak self] (cell: UICollectionViewCell) in
            if let index = self?.mediaBrowserView.index(for: cell) {
                self?.mediaBrowserView.reloadPages(at: [index])
            }
        }
        cell.willDisplayEmptyView = { [weak self] (cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            guard let self = self else {
                return
            }
            self.willDisplayEmptyView?(self, cell, emptyView, error)
        }
        if let imageCell = cell as? ImageCell {
            self.configureImageCell(imageCell, at: index)
        } else if let videoCell = cell as? VideoCell {
            self.configureVideoCell(videoCell, at: index)
        }
    }
    
    fileprivate func configureImageCell(_ cell: ImageCell, at index: Int) {
        guard let sourceItem = self.sourceItems[index] as? ImageSourceProtocol else {
            return
        }
        /// 当dismissingGesture失败时才会去响应scrollView的手势
        cell.zoomImageView.require(toFail: self.mediaBrowserView.dismissingGesture)
        /// zoomImageView修改器
        cell.zoomImageView.modifier = self.zoomImageViewModifier
        
        /// 取消请求
        self.webImageMediator?.cancelImageRequest(for: cell.zoomImageView.imageView)
        
        let updateData = { [weak cell] (image: UIImage?, error: NSError?, cancelled: Bool, finished: Bool) in
            guard let cell = cell else {
                return
            }
            cell.zoomImageView.image = image
            /// 解决网络图片下载完成后不播放的问题
            cell.zoomImageView.startAnimating()
            cell.setError(error, cancelled: cancelled, finished: finished)
        }
        let updateProgress = { [weak cell] (receivedSize: Int64, expectedSize: Int64) in
            guard let cell = cell else {
                return
            }
            let progress = Progress(totalUnitCount: expectedSize)
            progress.completedUnitCount = receivedSize
            cell.setProgress(progress)
        }
        /// 如果存在image, 且imageUrl为nil时, 则代表是本地图片, 无须网络请求
        if let image = sourceItem.image, sourceItem.imageUrl == nil {
            updateData(image, nil, false, true)
        } else {
            let url: URL? = sourceItem.imageUrl
            self.webImageMediator?.setImage(for: cell.zoomImageView.imageView,
                                            url: url,
                                            thumbImage: sourceItem.thumbImage,
                                            setImageBlock: { (image: UIImage?, imageData: Data?) in
                updateData(image, nil, false, true)
            }, progress: { (receivedSize: Int64, expectedSize: Int64) in
                updateProgress(receivedSize, expectedSize)
            }, completed: { (image: UIImage?, imageData: Data?, error: NSError?, cancelled: Bool, finished: Bool) in
                updateData(image, error, cancelled, finished)
            })
        }
    }
    
    fileprivate func configureVideoCell(_ cell: VideoCell, at index: Int) {
        guard let sourceItem = self.sourceItems[index] as? VideoSourceProtocol else {
            return
        }
        cell.videoPlayerView.thumbImage = sourceItem.thumbImage
        /// 前后url不相同时需要释放之前的player, 否则会先显示之前的画面, 再显示当前的
        if cell.videoPlayerView.url != sourceItem.videoUrl {
            cell.videoPlayerView.releasePlayer()
        }
        cell.videoPlayerView.url = sourceItem.videoUrl
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forPageAt index: Int) {
        if let imageCell = cell as? ImageCell {
            imageCell.zoomImageView.startAnimating()
        } else if let videoCell = cell as? VideoCell {
            let status: Stauts = videoCell.videoPlayerView.status
            if status == .ready || status == .paused {
                videoCell.videoPlayerView.play()
            }
        }
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forPageAt index: Int) {
        if let imageCell = cell as? ImageCell {
            imageCell.zoomImageView.stopAnimating()
        } else if let videoCell = cell as? VideoCell {
            videoCell.videoPlayerView.reset()
        }
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom index: Int, toIndex: Int) {
        if let sourceView = self.sourceViewForPageAtIndex?(self, index) {
            sourceView.isHidden = false
        }
        if let sourceView = self.sourceViewForPageAtIndex?(self, toIndex) {
            sourceView.isHidden = true
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewGestureDelegate {
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        self.hide()
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        guard let imageCell = self.currentPageCell as? ImageCell else {
            return
        }
        let zoomImageView = imageCell.zoomImageView
        let minimumZoomScale = zoomImageView.minimumZoomScale
        if zoomImageView.zoomScale != minimumZoomScale {
            zoomImageView.setZoom(scale: minimumZoomScale)
        } else {
            let gesturePoint: CGPoint = gestureRecognizer.location(in: zoomImageView.contentView)
            zoomImageView.zoom(to: gesturePoint)
        }
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPressTouch gestureRecognizer: UILongPressGestureRecognizer) {
        self.onLongPress?(self)
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissingShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool {
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
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissingChanged gestureRecognizer: UIPanGestureRecognizer) {
        let gestureRecognizerView: UIView = gestureRecognizer.view ?? mediaBrowserView
        switch gestureRecognizer.state {
        case .began:
            self.gestureBeganLocation = gestureRecognizer.location(in: gestureRecognizerView)
            self.transitionInteractiver.begin()
            self.hide()
            break
        case .changed:
            let location: CGPoint = gestureRecognizer.location(in: gestureRecognizerView)
            let horizontalDistance: CGFloat = location.x - self.gestureBeganLocation.x
            var verticalDistance: CGFloat = location.y - self.gestureBeganLocation.y
            let height: NSNumber = NSNumber(value: Double(gestureRecognizerView.bounds.height / 2))
            var ratio: CGFloat = 1.0
            var alpha: CGFloat = 1.0
            if  verticalDistance > 0 {
                ratio = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.4], extrapolateLeft: .clamp, extrapolateRight: .clamp)
                alpha = JSCoreHelper.interpolateValue(verticalDistance, inputRange: [0, height], outputRange: [1.0, 0.2], extrapolateLeft: .clamp, extrapolateRight: .clamp)
            } else {
                verticalDistance = -JSCoreHelper.bounce(fromValue: 0, toValue: height.doubleValue, time: abs(verticalDistance) / height.doubleValue, coeff: 1.2)
            }
            let transform = CGAffineTransform(translationX: horizontalDistance, y: verticalDistance).scaledBy(x: ratio, y: ratio)
            self.currentPageCell?.transform = transform
            self.transitionAnimatorViews?.forEach { (subview) in
                subview.alpha = alpha
            }
            break
        case .ended, .cancelled, .failed:
            let location: CGPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            let verticalDistance: CGFloat = location.y - self.gestureBeganLocation.y
            if verticalDistance > self.dismissWhenSlidingDistance {
                self.beginDismissingAnimation()
            } else {
                self.resetDismissingAnimation()
            }
            break
        default:
            break
        }
    }
    
    fileprivate func beginDismissingAnimation() {
        if let context = self.transitionInteractiver.context {
            self.transitionAnimator.performAnimation(using: context, isEntering: false) { finished in
                self.transitionInteractiver.finish()
            }
        } else {
            self.resetDismissingAnimation()
        }
    }
    
    fileprivate func resetDismissingAnimation() {
        self.gestureBeganLocation = CGPoint.zero
        UIView.animate(withDuration: self.transitionAnimator.duration, delay: 0, options: AnimationOptionsCurveOut, animations: {
            self.currentPageCell?.transform = CGAffineTransform.identity
            self.transitionAnimatorViews?.forEach { (subview) in
                subview.alpha = 1.0
            }
        }) { finished in
            self.transitionInteractiver.cancel()
        }
    }
    
}

extension MediaBrowserViewController: UIViewControllerTransitioningDelegate, TransitionAnimatorDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator.type = .presenting
        return self.transitionAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator.type = .dismiss
        return self.transitionAnimator
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.transitionInteractiver.type = .presenting
        return self.transitionInteractiver.wantsInteractiveStart ? self.transitionInteractiver : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.transitionInteractiver.type = .dismiss
        return self.transitionInteractiver.wantsInteractiveStart ? self.transitionInteractiver : nil
    }
    
    public var transitionSourceView: UIView? {
        return self.sourceViewForPageAtIndex?(self, self.currentPage)
    }
    
    public var transitionThumbImage: UIImage? {
        let sourceItem = self.sourceItems[self.currentPage]
        if let sourceItem = sourceItem as? ImageSourceProtocol {
            if let image = sourceItem.image != nil ? sourceItem.image : sourceItem.thumbImage {
                return image
            } else if let imageCell = self.currentPageCell as? ImageCell {
                return imageCell.zoomImageView.isDisplayImageView ? imageCell.zoomImageView.image : nil
            }
        } else if let sourceItem = sourceItem as? VideoSourceProtocol {
            if let image = sourceItem.thumbImage {
                return image
            } else if let videoCell = self.currentPageCell as? VideoCell {
                return videoCell.videoPlayerView.thumbImage
            }
        }
        return nil
    }
    
    public var transitionTargetView: UIView? {
        return self.currentPageCell
    }
    
    public var transitionTargetFrame: CGRect {
        if let imageCell = self.currentPageCell as? ImageCell {
            return imageCell.zoomImageView.contentViewFrame
        } else if let videoCell = self.currentPageCell as? VideoCell {
            return videoCell.videoPlayerView.contentViewFrame
        }
        return CGRect.zero
    }
    
    public var transitionAnimatorViews: [UIView]? {
        var animatorViews: [UIView] = []
        if let dimmingView = self.mediaBrowserView.dimmingView {
            animatorViews.append(dimmingView)
        }
        self.view.subviews.forEach { (subview) in
            if subview != self.mediaBrowserView {
                animatorViews.append(subview)
            }
        }
        return animatorViews
    }
    
}

extension MediaBrowserViewController {
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
}

extension MediaBrowserViewController {
    
    open override var shouldAutorotate: Bool {
        return self.presentedFromViewController?.shouldAutorotate ?? true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.presentedFromViewController?.supportedInterfaceOrientations ?? .allButUpsideDown
    }
    
}
