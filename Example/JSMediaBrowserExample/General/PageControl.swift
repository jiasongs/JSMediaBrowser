//
//  PageControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/24.
//

import UIKit
import JSCoreKit
import JSMediaBrowser

@objc class PageControl: UIPageControl, ToolViewProtocol {
    
    weak var browserViewController: MediaBrowserViewController?
    
    func didAddToSuperview(in viewController: MediaBrowserViewController) {
        self.browserViewController = viewController
        self.sourceItemsDidChange(in: viewController)
        if let browserView = viewController.browserView {
            self.currentPage = browserView.currentPage
        }
        let bottom = JSCoreHelper.isNotchedScreen ? JSCoreHelper.safeAreaInsetsForDeviceWithNotch.bottom : 20
        self.snp.makeConstraints { (make) in
            make.width.equalTo(viewController.view.snp.width).multipliedBy(0.5)
            make.centerX.equalTo(viewController.view.snp.centerX)
            make.bottom.equalTo(viewController.view.snp.bottom).offset(-bottom)
            make.height.equalTo(30)
        }
        self.addTarget(self, action: #selector(self.handlePageControlEvent), for: .valueChanged)
    }
    
    func sourceItemsDidChange(in viewController: MediaBrowserViewController) {
        if let sourceItems = viewController.sourceItems {
            self.numberOfPages = sourceItems.count
        }
    }
    
    func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController) {
        if let browserView = viewController.browserView {
            self.currentPage = browserView.currentPage
        }
    }
    
    @objc func handlePageControlEvent() -> Void {
        self.browserViewController?.browserView?.setCurrentPage(self.currentPage, animated: false)
    }
    
}
