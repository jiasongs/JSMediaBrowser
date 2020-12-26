//
//  PageControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/24.
//

import UIKit
import JSCoreKit
import JSMediaBrowser

class PageControl: UIPageControl, ToolViewProtocol {
    
    weak var browserViewController: MediaBrowserViewController?
    
    func sourceItemsDidChange(for browserViewController: MediaBrowserViewController) {
        if let sourceItems = browserViewController.sourceItems {
            self.numberOfPages = sourceItems.count
        }
    }
    
    func viewDidLoad(for browserViewController: MediaBrowserViewController) {
        self.browserViewController = browserViewController
        self.sourceItemsDidChange(for: browserViewController)
        if let browserView = browserViewController.browserView {
            self.currentPage = browserView.currentPage
        }
        let bottom = JSCoreHelper.isNotchedScreen() ? JSCoreHelper.safeAreaInsetsForDeviceWithNotch().bottom : 20
        self.snp.makeConstraints { (make) in
            make.width.equalTo(browserViewController.view.snp.width).multipliedBy(0.5)
            make.height.equalTo(30)
            make.centerX.equalTo(browserViewController.view.snp.centerX)
            make.bottom.equalTo(browserViewController.view.snp.bottom).offset(-bottom)
        }
        self.addTarget(self, action: #selector(self.handlePageControlEvent), for: .valueChanged)
    }
    
    func willScrollHalf(for browserViewController: MediaBrowserViewController, fromIndex: Int, toIndex: Int) {
        if let browserView = browserViewController.browserView {
            self.currentPage = browserView.currentPage
        }
    }
    
    @objc func handlePageControlEvent() -> Void {
        self.browserViewController?.browserView?.setCurrentPage(self.currentPage, animated: false)
    }

}
