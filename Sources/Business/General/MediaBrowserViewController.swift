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
    
    open weak var delegate: MediaBrowserViewControllerDelegate?
    
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
    
    open var dataSource: [DataItemProtocol]? {
        didSet {
            guard self.isViewLoaded else {
                return
            }
            
            self.mediaBrowserView.reloadData()
        }
    }
    
    open var webImageMediator: WebImageMediator?
    
    open var zoomImageViewModifier: ZoomImageViewModifier?
    
    open var transitionAnimatorModifier: TransitionAnimatorModifier? {
        didSet {
            self.transitionAnimator.modifier = self.transitionAnimatorModifier
        }
    }
    
    open var sourceViewForPageAtIndex: ((MediaBrowserViewController, Int) -> UIView?)?
    open var sourceRectForPageAtIndex: ((MediaBrowserViewController, Int) -> CGRect)?
    
    open var dismissWhenSlidingDistance: CGFloat = 70
    
    open private(set) lazy var mediaBrowserView: MediaBrowserView = {
        return MediaBrowserView()
    }()
    
    open private(set) weak var presentedFromViewController: UIViewController?
    
    private lazy var transitionAnimator: TransitionAnimator = {
        let animator = TransitionAnimator()
        animator.delegate = self
        return animator
    }()
    
    private lazy var transitionInteractiver: TransitionInteractiver = {
        let interactiver = TransitionInteractiver()
        return interactiver
    }()
    
    private var gestureBeganLocation: CGPoint = CGPoint.zero
    
    private weak var cacheSourceView: UIView?
    
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
        
        self.cacheSourceView = self.sourceViewForPageAtIndex?(self, self.currentPage)
        self.cacheSourceView?.isHidden = true
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cacheSourceView?.isHidden = false
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.cacheSourceView?.isHidden = false
        coordinator.animateAlongsideTransition(in: self.view, animation: nil) { context in
            guard self.view.window != nil else {
                return
            }
            self.cacheSourceView = self.sourceViewForPageAtIndex?(self, self.currentPage)
            self.cacheSourceView?.isHidden = true
        }
    }
    
}

extension MediaBrowserViewController {
    
    @objc open var currentPage: Int {
        get {
            return self.mediaBrowserView.currentPage
        }
        set {
            self.mediaBrowserView.currentPage = newValue
        }
    }
    
    @objc open var totalUnitPage: Int {
        guard self.mediaBrowserView.dataSource != nil else {
            return self.numberOfPages(in: self.mediaBrowserView)
        }
        
        return self.mediaBrowserView.totalUnitPage
    }
    
    @objc open var currentPageCell: UICollectionViewCell? {
        return self.mediaBrowserView.currentPageCell
    }
    
    @objc open func setCurrentPage(_ index: Int, animated: Bool, completion: (() -> Void)? = nil) {
        self.mediaBrowserView.setCurrentPage(index, animated: animated, completion: completion)
    }
    
    @objc open func show(from sender: UIViewController,
                         navigationController: UINavigationController? = nil,
                         animated: Bool,
                         completion: (() -> Void)? = nil) {
        self.presentedFromViewController = sender
        
        let viewController = navigationController ?? self
        viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.transitioningDelegate = self
        
        var presenter = sender
        guard presenter.isViewLoaded else {
            assertionFailure()
            return
        }
        if !(presenter is UITabBarController), let tabBarController = presenter.tabBarController, tabBarController.isViewLoaded {
            if !tabBarController.tabBar.isHidden && tabBarController.tabBar.bounds.height > 0 && !presenter.hidesBottomBarWhenPushed {
                presenter = tabBarController
            }
        }
        if let presentedViewController = presenter.presentedViewController {
            presenter = presentedViewController
        }
        presenter.present(viewController, animated: animated, completion: completion)
    }
    
    @objc open func hide(animated: Bool, completion: (() -> Void)? = nil) {
        if self.isPresented {
            self.dismiss(animated: animated, completion: completion)
        } else {
            self.navigationController?.popViewController(animated: animated)
            if let transitionCoordinator = self.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: nil) { context in
                    completion?()
                }
            } else {
                completion?()
            }
        }
    }
    
    @objc open var isPresented: Bool {
        return self.presentedFromViewController != nil
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    @objc open func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, cellForPageAt index: Int) -> UICollectionViewCell {
        var cell: BasisCell?
        let dataItem = self.dataSource?[index]
        if dataItem is ImageDataItemProtocol {
            cell = mediaBrowserView.dequeueReusableCell(ImageCell.self, at: index)
        } else if dataItem is VideoDataItemProtocol {
            cell = mediaBrowserView.dequeueReusableCell(VideoCell.self, at: index)
        }
        guard let cell = cell else {
            return mediaBrowserView.dequeueReusableCell(UICollectionViewCell.self, at: index)
        }
        self.configureCell(cell, at: index)
        return cell
    }
    
    @objc open func configureCell(_ cell: BasisCell, at index: Int) {
        cell.onPressEmpty = { [weak self] (cell: UICollectionViewCell) in
            if let index = self?.mediaBrowserView.index(for: cell) {
                self?.mediaBrowserView.reloadPages(at: [index])
            }
        }
        cell.willDisplayEmptyView = { [weak self] (cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            guard let self = self else {
                return
            }
            self.delegate?.mediaBrowserViewController(self, willDisplay: emptyView, error: error)
        }
        if let imageCell = cell as? ImageCell {
            self.configureImageCell(imageCell, at: index)
        } else if let videoCell = cell as? VideoCell {
            self.configureVideoCell(videoCell, at: index)
        }
    }
    
    @objc open func configureImageCell(_ cell: ImageCell, at index: Int) {
        guard let dataItem = self.dataSource?[index] as? ImageDataItemProtocol else {
            return
        }
        /// 当dismissingGesture失败时才会去响应scrollView的手势
        cell.zoomImageView.require(toFail: self.mediaBrowserView.dismissingGesture)
        /// zoomImageView修改器
        cell.zoomImageView.modifier = self.zoomImageViewModifier
        
        let webImageMediator = dataItem.webImageMediator ?? self.webImageMediator
        /// 取消请求
        webImageMediator?.cancelImageRequest(for: cell)
        
        let updateProgress = { [weak cell] (receivedSize: Int64, expectedSize: Int64) in
            let progress = Progress(totalUnitCount: expectedSize)
            progress.completedUnitCount = receivedSize
            cell?.setProgress(progress)
        }
        let updateImage = { [weak cell] (image: UIImage?) in
            guard let cell = cell else {
                return
            }
            cell.zoomImageView.image = image
            /// 解决网络图片下载完成后不播放的问题
            cell.zoomImageView.startAnimating()
        }
        let updateCell = { [weak cell] (error: NSError?, cancelled: Bool) in
            cell?.setError(error, cancelled: cancelled)
        }
        /// 如果存在image, 且imageUrl为nil时, 则代表是本地图片, 无须网络请求
        if let image = dataItem.image, dataItem.imageUrl == nil {
            updateImage(image)
            updateCell(nil, false)
        } else {
            let url: URL? = dataItem.imageUrl
            webImageMediator?.setImage(
                for: cell,
                url: url,
                thumbImage: dataItem.thumbImage,
                setImageBlock: { (image: UIImage?) in
                    updateImage(image)
                },
                progress: { (receivedSize: Int64, expectedSize: Int64) in
                    updateProgress(receivedSize, expectedSize)
                },
                completed: { result in
                    switch result {
                    case .success(let value):
                        updateImage(value.image)
                        updateCell(nil, false)
                    case .failure(let error):
                        updateImage(nil)
                        updateCell(error.error, error.cancelled)
                    }
                })
        }
    }
    
    @objc open func configureVideoCell(_ cell: VideoCell, at index: Int) {
        guard let dataItem = self.dataSource?[index] as? VideoDataItemProtocol else {
            return
        }
        cell.videoPlayerView.thumbImage = dataItem.thumbImage
        /// 前后url不相同时需要释放之前的player, 否则会先显示之前的画面, 再显示当前的
        if cell.videoPlayerView.url != dataItem.videoUrl {
            cell.videoPlayerView.releasePlayer()
        }
        cell.setProgress(Progress())
        cell.videoPlayerView.isAutoPlay = !cell.isHidden
        cell.videoPlayerView.url = dataItem.videoUrl
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
        self.cacheSourceView?.isHidden = false
        self.cacheSourceView = self.sourceViewForPageAtIndex?(self, toIndex)
        self.cacheSourceView?.isHidden = true
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didScrollTo index: Int) {
        
    }
    
    @objc open func mediaBrowserViewDidScroll(_ mediaBrowserView: MediaBrowserView) {
        
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewGestureDelegate {
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        guard self.isPresented else {
            return
        }
        
        self.hide(animated: true)
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        guard let imageCell = self.currentPageCell as? ImageCell else {
            return
        }
        let zoomImageView = imageCell.zoomImageView
        let minimumZoomScale = zoomImageView.minimumZoomScale
        if zoomImageView.zoomScale != minimumZoomScale {
            zoomImageView.setZoom(scale: minimumZoomScale, animated: true)
        } else {
            let gesturePoint: CGPoint = gestureRecognizer.location(in: zoomImageView.contentView)
            zoomImageView.zoom(to: gesturePoint, animated: true)
        }
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPressTouch gestureRecognizer: UILongPressGestureRecognizer) {
        
    }
    
    @objc open func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissingShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard let imageCell = self.currentPageCell as? ImageCell else {
            return true
        }
        let zoomImageView: ZoomImageView = imageCell.zoomImageView
        let velocity: CGPoint = gestureRecognizer.velocity(in: gestureRecognizer.view)
        let minY: CGFloat = ceil(zoomImageView.minContentOffset.y)
        let maxY: CGFloat = floor(zoomImageView.maxContentOffset.y)
        let scrollView = zoomImageView.scrollView
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
            if self.isPresented {
                self.hide(animated: true)
            }
        case .changed:
            let location = gestureRecognizer.location(in: gestureRecognizerView)
            let horizontalDistance = location.x - self.gestureBeganLocation.x
            var verticalDistance = location.y - self.gestureBeganLocation.y
            let height = NSNumber(value: Double(gestureRecognizerView.bounds.height / 2))
            var ratio = 1.0
            var alpha = 1.0
            if self.isPresented {
                ratio = JSCoreHelper.interpolateValue(abs(verticalDistance), inputRange: [0, height], outputRange: [1.0, 0.4], extrapolateLeft: .clamp, extrapolateRight: .clamp)
                alpha = JSCoreHelper.interpolateValue(abs(verticalDistance), inputRange: [0, height], outputRange: [1.0, 0.2], extrapolateLeft: .clamp, extrapolateRight: .clamp)
            } else {
                verticalDistance = -JSCoreHelper.bounce(fromValue: 0, toValue: verticalDistance > 0 ? -height.doubleValue : height.doubleValue, time: abs(verticalDistance) / height.doubleValue, coeff: 1.2)
            }
            let transform = CGAffineTransform(translationX: horizontalDistance, y: verticalDistance).scaledBy(x: ratio, y: ratio)
            self.currentPageCell?.transform = transform
            self.transitionAnimatorViews?.forEach { (subview) in
                subview.alpha = alpha
            }
        case .ended, .cancelled, .failed:
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            let verticalDistance = location.y - self.gestureBeganLocation.y
            if abs(verticalDistance) > self.dismissWhenSlidingDistance && self.isPresented {
                self.beginDismissingAnimation()
            } else {
                self.resetDismissingAnimation()
            }
        default:
            break
        }
    }
    
    @objc open func beginDismissingAnimation() {
        if let context = self.transitionInteractiver.context {
            self.transitionAnimator.performAnimation(using: context, isEntering: false) { finished in
                self.transitionInteractiver.finish()
            }
        } else {
            self.resetDismissingAnimation()
        }
    }
    
    @objc open func resetDismissingAnimation() {
        self.gestureBeganLocation = CGPoint.zero
        UIView.animate(withDuration: self.transitionAnimator.duration, delay: 0, options: JSCoreHelper.animationOptionsCurveOut) {
            self.currentPageCell?.transform = CGAffineTransform.identity
            self.transitionAnimatorViews?.forEach { (subview) in
                subview.alpha = 1.0
            }
        } completion: { finished in
            self.transitionInteractiver.cancel()
        }
    }
    
}

extension MediaBrowserViewController: UIViewControllerTransitioningDelegate, TransitionAnimatorDelegate {
    
    @objc open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator.type = .presenting
        return self.transitionAnimator
    }
    
    @objc open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator.type = .dismiss
        return self.transitionAnimator
    }
    
    @objc open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.transitionInteractiver.type = .presenting
        return self.transitionInteractiver.wantsInteractiveStart ? self.transitionInteractiver : nil
    }
    
    @objc open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.transitionInteractiver.type = .dismiss
        return self.transitionInteractiver.wantsInteractiveStart ? self.transitionInteractiver : nil
    }
    
    @objc open var transitionSourceView: UIView? {
        return self.cacheSourceView
    }
    
    @objc open var transitionSourceRect: CGRect {
        return self.sourceRectForPageAtIndex?(self, self.currentPage) ?? CGRect.zero
    }
    
    @objc open var transitionThumbImage: UIImage? {
        let dataItem = self.dataSource?[self.currentPage]
        if let dataItem = dataItem as? ImageDataItemProtocol {
            if let imageCell = self.currentPageCell as? ImageCell {
                return imageCell.zoomImageView.isDisplayImageView ? imageCell.zoomImageView.image : nil
            } else if let image = dataItem.image != nil ? dataItem.image : dataItem.thumbImage {
                return image
            }
        } else if let dataItem = dataItem as? VideoDataItemProtocol {
            if let videoCell = self.currentPageCell as? VideoCell {
                return videoCell.videoPlayerView.thumbImage
            } else if let image = dataItem.thumbImage {
                return image
            }
        }
        return nil
    }
    
    @objc open var transitionTargetView: UIView? {
        return self.currentPageCell
    }
    
    @objc open var transitionTargetFrame: CGRect {
        if let imageCell = self.currentPageCell as? ImageCell {
            return self.transitionThumbImage != nil ? imageCell.zoomImageView.contentViewFrame : CGRect.zero
        } else if let videoCell = self.currentPageCell as? VideoCell {
            return self.transitionThumbImage != nil ? videoCell.videoPlayerView.contentViewFrame : CGRect.zero
        }
        return CGRect.zero
    }
    
    @objc open var transitionAnimatorViews: [UIView]? {
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
    
    @objc open func transitionViewWillMoveToSuperview(_ transitionView: UIView) {
        self.mediaBrowserView.addSubview(transitionView)
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
        guard let orientationViewController = self.orientationViewController else {
            return true
        }
        
        return orientationViewController.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let orientationViewController = self.orientationViewController else {
            return .allButUpsideDown
        }
        
        return orientationViewController.supportedInterfaceOrientations
    }
    
    private var orientationViewController: UIViewController? {
        if let presentedFromViewController = self.presentedFromViewController {
            return presentedFromViewController
        } else if let viewControllers = self.navigationController?.viewControllers, let index = viewControllers.firstIndex(of: self) {
            return index > 0 ? viewControllers[index - 1] : nil
        }
        return nil
    }
    
}
