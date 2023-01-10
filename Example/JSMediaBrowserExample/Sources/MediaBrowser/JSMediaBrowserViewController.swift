//
//  JSMediaBrowserViewController.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2023/1/5.
//  Copyright © 2023 jiasong. All rights reserved.
//

import UIKit
import JSMediaBrowser
import SnapKit
import QMUIKit
import SDWebImage

class JSMediaBrowserViewController: MediaBrowserViewController {
    
    lazy var shareControl: ShareControl = {
        return ShareControl().then {
            $0.mediaBrowserVC = self
        }
    }()
    
    lazy var pageControl: PageControl = {
        return PageControl().then {
            $0.mediaBrowserVC = self
        }
    }()
    
    fileprivate lazy var delegator: JSMediaBrowserViewControllerDelegator = {
        return JSMediaBrowserViewControllerDelegator()
    }()
    
    override var dataSource: [DataItemProtocol] {
        didSet {
            self.updatePageControl(for: self.currentPage)
        }
    }
    
    override func didInitialize() {
        super.didInitialize()
        self.webImageMediator = SDWebImageMediator()
        self.zoomImageViewModifier = SDZoomImageViewModifier()
        self.transitionAnimatorModifier = JSMediaBrowserTransitionAnimatorModifier()
        self.delegate = self.delegator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.shareControl)
        self.shareControl.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(QMUIHelper.isNotchedScreen ? 0 : -20)
            make.height.equalTo(30)
        }
        self.view.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.snp.width).multipliedBy(0.5)
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(QMUIHelper.isNotchedScreen ? 0 : -20)
            make.height.equalTo(30)
        }
        
        self.updatePageControl(for: self.currentPage)
    }
    
}

extension JSMediaBrowserViewController {
    
    func updatePageControl(for index: Int) {
        self.pageControl.numberOfPages = self.totalUnitPage
        self.pageControl.currentPage = index
    }
    
}

extension JSMediaBrowserViewController {
    
    override func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom index: Int, toIndex: Int) {
        super.mediaBrowserView(mediaBrowserView, willScrollHalfFrom: index, toIndex: toIndex)
        self.updatePageControl(for: toIndex)
        
        print("mediaBrowserView willScrollHalfFrom: \(index) toIndex: \(toIndex)")
    }
    
    override func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, didScrollTo index: Int) {
        super.mediaBrowserView(mediaBrowserView, didScrollTo: index)
        
        print("mediaBrowserView didScrollTo \(index)")
    }
    
    override func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPressTouch gestureRecognizer: UILongPressGestureRecognizer) {
        super.mediaBrowserView(mediaBrowserView, longPressTouch: gestureRecognizer)
        QMUITips.show(withText: "长按")
    }
    
}

fileprivate class JSMediaBrowserViewControllerDelegator: MediaBrowserViewControllerDelegate {
    
    public func mediaBrowserViewController(_ mediaBrowserViewController: MediaBrowserViewController, willDisplay emptyView: EmptyView, error: NSError) {
        emptyView.image = UIImage(named: "picture_fail")
        emptyView.title = "\(String(describing: error.localizedDescription))"
    }
    
}

fileprivate struct JSMediaBrowserTransitionAnimatorModifier: TransitionAnimatorModifier {
    
    public func imageView(in transitionAnimator: TransitionAnimator) -> UIImageView {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = false
        return imageView
    }
    
}
