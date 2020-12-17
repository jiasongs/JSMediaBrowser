//
//  MediaBrowserViewController.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

import UIKit
import JSCoreKit

@objc(MediaBrowserViewControllerTransitioningStyle)
enum TransitioningStyle: Int {
    case zoom
    case fade
}

@objc class MediaBrowserViewController: UIViewController {
    
    @objc open var browserView: MediaBrowserView?
    @objc open var sourceItems: Array<BaseEntity>? {
        didSet {
            var array: Array<BaseLoaderEntity> = Array()
            sourceItems?.forEach({ (item) in
                if item.isKind(of: ImageEntity.self) {
                    let loader: ImageLoaderEntity = ImageLoaderEntity()
                    loader.sourceItem = item
                    loader.webImageMediator = nil
                    array.append(loader)
                }
            })
            loaderItems = array
        }
    }
    
    @objc open var transitioningAnimator: UIViewControllerAnimatedTransitioning? {
        didSet {
            if let animator = transitioningAnimator as? TransitionAnimator, animator.isKind(of: TransitionAnimator.self) {
                animator.delegate = self
            }
        }
    }
    @objc open var presentingStyle: TransitioningStyle = .zoom {
        didSet {
            dismissingStyle = presentingStyle
            if let animator = transitioningAnimator as? TransitionAnimator, animator.isKind(of: TransitionAnimator.self) {
                animator.presentingStyle = presentingStyle
            }
        }
    }
    @objc open var dismissingStyle: TransitioningStyle = .zoom {
        didSet {
            if let animator = transitioningAnimator as? TransitionAnimator, animator.isKind(of: TransitionAnimator.self) {
                animator.dismissingStyle = dismissingStyle
            }
        }
    }
    
    
    private var loaderItems: Array<LoaderProtocol>?
    private var imageCellIdentifier = "ImageCell"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.didInitialize()
    }
    
    required init?(coder: NSCoder) {
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
    
}

extension MediaBrowserViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0)
        if let browserView = self.browserView {
            browserView.delegate = self
            browserView.dataSource = self
            browserView.gestureDelegate = self
            self.view.addSubview(browserView)
            
            browserView.registerClass(ImageCell.self, forCellWithReuseIdentifier: imageCellIdentifier)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let browserView = self.browserView {
            browserView.js_frameApplyTransform = self.view.bounds
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let browserView = self.browserView {
            browserView.reloadData()
            browserView.collectionView?.layoutIfNeeded()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int {
        return loaderItems?.count ?? 0
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: BaseCell?
        guard let loaderItem = loaderItems?[indexPath.item] else { return UICollectionViewCell() }
        if let loaderItem = loaderItem as? ImageLoaderEntity, let sourceItem = loaderItem.sourceItem, sourceItem.isKind(of: ImageEntity.self) {
            cell = browserView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as? BaseCell
            cell?.updateCell(loaderEntity: loaderItem, at: indexPath)
        }
        return cell!
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
    func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imageCell = cell as? ImageCell, imageCell.isKind(of: ImageCell.self) {
            imageCell.zoomImageView?.revertZooming()
        }
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imageCell = cell as? ImageCell, imageCell.isKind(of: ImageCell.self) {
            imageCell.zoomImageView?.revertZooming()
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewGestureDelegate {
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        self.hide(animated: true)
    }
    
    @objc func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        if let imageCell = mediaBrowserView.currentMidiaCell as? ImageCell, imageCell.isKind(of: ImageCell.self) {
            imageCell.zoomImageView?.zoom(from: gestureRecognizer, animated: true)
        }
    }
    
    @objc func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer) {
        
    }
    
    @objc func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissing gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat) {
        switch gestureRecognizer.state {
        case .changed:
            break
        case .ended:
            if (verticalDistance > mediaBrowserView.bounds.height / 2 / 3) {
                self.hide(animated: true)
            } else {
                mediaBrowserView.resetDismissingGesture()
            }
            break
        default:
            break
        }
    }
    
}

extension MediaBrowserViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitioningAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitioningAnimator
    }
    
}

extension MediaBrowserViewController: TransitionAnimatorDelegate {
    
    var sourceRect: CGRect {
        if let sourceItem = self.sourceItems?[browserView?.currentMediaIndex ?? 0] {
            return sourceItem.sourceRect
        }
        return CGRect.zero
    }
    
    var sourceView: UIView? {
        if let sourceItem = self.sourceItems?[browserView?.currentMediaIndex ?? 0] {
            return sourceItem.sourceView
        }
        return nil
    }
    
    var sourceCornerRadius: CGFloat {
        if let sourceItem = self.sourceItems?[browserView?.currentMediaIndex ?? 0] {
            if sourceItem.sourceCornerRadius > 0 {
                return sourceItem.sourceCornerRadius
            } else {
                return sourceItem.sourceView?.layer.cornerRadius ?? 0
            }
        }
        return 0
    }
    
    var contentView: UIView? {
        return self.browserView
    }
    
    var dimmingView: UIView? {
        return self.browserView?.dimmingView
    }
    
    var zoomView: UIView? {
        if let cell = self.browserView?.currentMidiaCell {
            return cell
        }
        return nil
    }
    
    var zoomContentView: UIView? {
        if let imageCell = self.browserView?.currentMidiaCell as? ImageCell, imageCell.isKind(of: ImageCell.self) {
            return imageCell.zoomImageView?.contentView
        }
        return nil
    }
    
    var zoomContentViewRect: CGRect {
        if let imageCell = self.browserView?.currentMidiaCell as? ImageCell, imageCell.isKind(of: ImageCell.self) {
            return imageCell.zoomImageView?.contentViewRectInZoomView() ?? CGRect.zero
        }
        return CGRect.zero
    }
    
    var zoomScollView: UIScrollView? {
        if let imageCell = self.browserView?.currentMidiaCell as? ImageCell, imageCell.isKind(of: ImageCell.self) {
            return imageCell.zoomImageView?.scrollView
        }
        return nil
    }
    
    func revertZooming() -> Void {
        if let imageCell = self.browserView?.currentMidiaCell as? ImageCell, imageCell.isKind(of: ImageCell.self) {
            guard let zoomImageView = imageCell.zoomImageView else { return }
            guard let scrollView = zoomImageView.scrollView else { return }
            zoomImageView.setZoom(scale: scrollView.minimumZoomScale, animated: true)
//            zoomImageView.revertZooming()
        }
    }
    
}
