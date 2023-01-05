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
    
    override var sourceItems: [SourceProtocol] {
        didSet {
            self.updatePageControl()
        }
    }
    
    override func didInitialize() {
        super.didInitialize()
        self.webImageMediator = SDWebImageMediator()
        self.zoomImageViewModifier = SDZoomImageViewModifier()
        self.delegate = self
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
        
        self.updatePageControl()
    }
    
}

extension JSMediaBrowserViewController {
    
    func updatePageControl() {
        self.pageControl.numberOfPages = self.totalUnitPage
        self.pageControl.currentPage = self.currentPage
    }
    
}

extension JSMediaBrowserViewController {
    
    override func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, willScrollHalfFrom index: Int, toIndex: Int) {
        super.mediaBrowserView(mediaBrowserView, willScrollHalfFrom: index, toIndex: toIndex)
        self.pageControl.currentPage = toIndex
    }
    
    override func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPressTouch gestureRecognizer: UILongPressGestureRecognizer) {
        super.mediaBrowserView(mediaBrowserView, longPressTouch: gestureRecognizer)
        QMUITips.show(withText: "长按")
    }
    
}

extension JSMediaBrowserViewController: MediaBrowserViewControllerDelegate {
    
    public func mediaBrowserViewController(_ mediaBrowserViewController: MediaBrowserViewController, willDisplay emptyView: EmptyView, error: NSError) {
        emptyView.image = UIImage(named: "picture_fail")
        emptyView.title = "\(String(describing: error.localizedDescription))"
    }
    
}
