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
    
    open lazy var mediaBrowserView: MediaBrowserView = {
        let mediaBrowserView = MediaBrowserView()
        return mediaBrowserView
    }()
    
    open lazy var transitionAnimator: TransitionAnimator = {
        let animator = TransitionAnimator()
        animator.delegate = self
        return animator
    }()
    
    open lazy var transitionInteractiver: TransitionInteractiver = {
        let interactiver = TransitionInteractiver()
        return interactiver
    }()
    
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
    
    open var modifier: MediaBrowserViewControllerModifier?
    
    open var additionalViews: [UIView & AdditionalViewProtocol] = [] {
        didSet {
            for additionalView in oldValue {
                additionalView.removeFromSuperview()
            }
            self.togglePrepareAdditionalViews()
        }
    }
    
#if BUSINESS_IMAGE
    open var webImageMediator: WebImageMediator?
    open var imageViewForZoomView: ((MediaBrowserViewController, ZoomImageView) -> UIImageView)?
    open var livePhotoViewForZoomView: ((MediaBrowserViewController, ZoomImageView) -> PHLivePhotoView)?
#endif
    
    open var cellForItemAtPage: ((MediaBrowserViewController, Int) -> UICollectionViewCell?)?
    open var configureCell: ((MediaBrowserViewController, UICollectionViewCell, Int) -> Void)?
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
    
    open var totalUnitPage: Int {
        return self.mediaBrowserView.totalUnitPage
    }
    
    open var currentPageCell: UICollectionViewCell? {
        return self.mediaBrowserView.currentPageCell
    }
    
    open var dismissWhenSlidingDistance: CGFloat = 60
    
    open private(set) weak var presentedFromViewController: UIViewController?
    
    fileprivate var gestureBeganLocation: CGPoint = CGPoint.zero
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() {
        if #available(iOS 11.0, *) {
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.extendedLayoutIncludesOpaqueBars = true
        self.accessibilityViewIsModal = true
    }
    
}

extension MediaBrowserViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
        self.mediaBrowserView.modifier = AnyMediaBrowserViewModifier(mediaBrowser: self)
        self.mediaBrowserView.plugin = AnyMediaBrowserViewPlugin(mediaBrowser: self)
        self.mediaBrowserView.gesturePlugin = self
        self.view.addSubview(self.mediaBrowserView)
        
        self.togglePrepareAdditionalViews()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mediaBrowserView.js_frameApplyTransform = self.view.bounds
        
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
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let sourceView = self.transitionSourceView, sourceView.isHidden {
            sourceView.isHidden = false
        }
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

extension MediaBrowserViewController {
    
    open func show(from sender: UIViewController,
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
    
    open func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(animated: animated, completion: completion)
    }
    
    open func dequeueReusableCell<Cell: UICollectionViewCell>(_ cellClass: Cell.Type,
                                                              reuseIdentifier: String? = nil,
                                                              at index: Int) -> Cell {
        return self.mediaBrowserView.dequeueReusableCell(cellClass, reuseIdentifier: reuseIdentifier, at: index)
    }
    
    open func dequeueReusableCell<Cell: UICollectionViewCell>(_ nibName: String,
                                                              bundle: Bundle? = Bundle.main,
                                                              reuseIdentifier: String? = nil,
                                                              at index: Int) -> Cell {
        return self.mediaBrowserView.dequeueReusableCell(nibName, bundle: bundle, reuseIdentifier: reuseIdentifier, at: index)
    }
    
    open func dequeueReusableCell<Cell: UICollectionViewCell>(_ storyboardReuseIdentifier: String, at index: Int) -> Cell {
        return self.mediaBrowserView.dequeueReusableCell(storyboardReuseIdentifier, at: index)
    }
    
    open func setCurrentPage(_ index: Int, animated: Bool = true) {
        self.mediaBrowserView.setCurrentPage(index, animated: animated)
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
        return self.transitionInteractiver.isInteractive ? self.transitionInteractiver : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        self.transitionInteractiver.type = .dismiss
        return self.transitionInteractiver.isInteractive ? self.transitionInteractiver : nil
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
        if let dimmingView = self.mediaBrowserView.dimmingView {
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

public struct AnyMediaBrowserViewModifier: MediaBrowserViewModifier {
    
    weak var mediaBrowser: MediaBrowserViewController?
    
    public func numberOfPages(in mediaBrowserView: MediaBrowserView) -> Int {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return 0
        }
        return mediaBrowserViewController.loaderItems.count
    }
    
    public func cellForPage(at index: Int, in mediaBrowserView: MediaBrowserView) -> UICollectionViewCell {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return mediaBrowserView.dequeueReusableCell(UICollectionViewCell.self, at: index)
        }
        
        var cell: UICollectionViewCell? = nil
        let loaderItem: LoaderProtocol = mediaBrowserViewController.loaderItems[index]
#if BUSINESS_IMAGE
        if let _ = loaderItem as? ImageLoaderProtocol {
            cell = mediaBrowserView.dequeueReusableCell(ImageCell.self, at: index)
        }
#endif
#if BUSINESS_VIDEO
        if let _ = loaderItem as? VideoLoaderProtocol {
            cell = mediaBrowserView.dequeueReusableCell(VideoCell.self, at: index)
        }
#endif
        if let basisCell = cell as? BasisCell {
            self.configureCell(basisCell, at: index)
        }
        return cell!
    }
    
    private func configureCell(_ cell: BasisCell, at index: Int) {
        cell.onEmptyPressAction = { (cell: UICollectionViewCell) in
            if let index: Int = self.mediaBrowser?.mediaBrowserView.index(for: cell), index != NSNotFound {
                self.mediaBrowser?.mediaBrowserView.reloadPages(at: [index])
            }
        }
        cell.willDisplayEmptyView = { (cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            guard let mediaBrowserViewController = self.mediaBrowser else {
                return
            }
            self.mediaBrowser?.willDisplayEmptyView?(mediaBrowserViewController, cell, emptyView, error)
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
    private func configureImageCell(_ cell: ImageCell, at index: Int) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
        /// 当dismissingGesture失败时才会去响应scrollView的手势
        cell.zoomImageView.require(toFail: mediaBrowserViewController.mediaBrowserView.dismissingGesture)
        if let loaderItem: ImageLoaderProtocol = mediaBrowserViewController.loaderItems[index] as? ImageLoaderProtocol {
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
    private func configureVideoCell(_ cell: VideoCell, at index: Int) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
        if  let sourceItem: VideoSourceProtocol = mediaBrowserViewController.loaderItems[index].sourceItem as? VideoSourceProtocol {
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

public struct AnyMediaBrowserViewPlugin: MediaBrowserViewPlugin {
    
    weak var mediaBrowser: MediaBrowserViewController?
    
    public func willDisplayCell(_ cell: UICollectionViewCell, forPageAt index: Int, in mediaBrowserView: MediaBrowserView) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
#if BUSINESS_IMAGE
        if let imageCell = cell as? ImageCell,
           let loaderItem: ImageLoaderProtocol = mediaBrowserViewController.loaderItems[index] as? ImageLoaderProtocol {
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
    
    public func didEndDisplayingCell(_ cell: UICollectionViewCell, forPageAt index: Int, in mediaBrowserView: MediaBrowserView)  {
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
    
    public func willScrollHalfFrom(_ index: Int, toIndex: Int, in mediaBrowserView: MediaBrowserView) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
        if let sourceView = mediaBrowserViewController.modifier?.sourceViewForPageAtIndex(index, in: mediaBrowserViewController) {
            sourceView.isHidden = false
        }
        if let sourceView = mediaBrowserViewController.modifier?.sourceViewForPageAtIndex(toIndex, in: mediaBrowserViewController) {
            sourceView.isHidden = true
        }
        for additionalView in mediaBrowserViewController.additionalViews {
            additionalView.willScrollHalf(fromIndex: index, toIndex: toIndex, in: mediaBrowserViewController)
        }
    }
    
    public func didScrollTo(_ index: Int, in mediaBrowserView: MediaBrowserView) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
        for additionalView in mediaBrowserViewController.additionalViews {
            additionalView.didScroll(to: index, in: mediaBrowserViewController)
        }
    }
    
}

public struct AnyMediaBrowserViewGesturePlugin: MediaBrowserViewGesturePlugin {
    
    weak var mediaBrowser: MediaBrowserViewController?
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
        mediaBrowserViewController.hide()
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
#if BUSINESS_IMAGE
        if let imageCell = mediaBrowserViewController.currentPageCell as? ImageCell {
            let zoomImageView = imageCell.zoomImageView
            let minimumZoomScale = zoomImageView.minimumZoomScale
            if zoomImageView.zoomScale != minimumZoomScale {
                zoomImageView.setZoom(scale: minimumZoomScale)
            } else {
                let gesturePoint: CGPoint = gestureRecognizer.location(in: zoomImageView.contentView)
                zoomImageView.zoom(to: gesturePoint)
            }
        }
#endif
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
        mediaBrowserViewController.onLongPress?(self)
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissingShouldBegin gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return true
        }
#if BUSINESS_IMAGE
        guard let imageCell = mediaBrowserViewController.currentPageCell as? ImageCell else {
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
        return false
#endif
    }
    
    public func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissingChanged gestureRecognizer: UIPanGestureRecognizer) {
        guard let mediaBrowserViewController = self.mediaBrowser else {
            return
        }
        let gestureRecognizerView: UIView = gestureRecognizer.view ?? mediaBrowserViewController.mediaBrowserView
        switch gestureRecognizer.state {
        case .began:
            mediaBrowserViewController.gestureBeganLocation = gestureRecognizer.location(in: gestureRecognizerView)
            mediaBrowserViewController.transitionInteractiver.begin()
            mediaBrowserViewController.hide()
            break
        case .changed:
            let location: CGPoint = gestureRecognizer.location(in: gestureRecognizerView)
            let horizontalDistance: CGFloat = location.x - mediaBrowserViewController.gestureBeganLocation.x
            var verticalDistance: CGFloat = location.y - mediaBrowserViewController.gestureBeganLocation.y
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
            mediaBrowserViewController.currentPageCell?.transform = transform
            
            for additionalView in mediaBrowserViewController.additionalViews {
                additionalView.alpha = alpha
            }
            mediaBrowserViewController.mediaBrowserView.dimmingView?.alpha = alpha
            mediaBrowserViewController.transitionInteractiver.update(alpha)
            break
        case .ended, .cancelled, .failed:
            let location: CGPoint = gestureRecognizer.location(in: gestureRecognizer.view)
            let verticalDistance: CGFloat = location.y - mediaBrowserViewController.gestureBeganLocation.y
            if verticalDistance > mediaBrowserViewController.dismissWhenSlidingDistance {
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
            self.mediaBrowserView.dimmingView?.alpha = 1.0
            for additionalView in self.additionalViews {
                additionalView.alpha = 1.0
            }
        }) { finished in
            self.transitionInteractiver.cancel()
        }
    }
    
}
