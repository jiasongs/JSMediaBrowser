//
//  PageControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/24.
//

import UIKit
import JSCoreKit
import JSMediaBrowser
import SnapKit
import QMUIKit

class PageControl: UIPageControl, AdditionalViewProtocol {
    
    weak var browserViewController: MediaBrowserViewController?
    
    func prepare(in viewController: MediaBrowserViewController) {
        self.browserViewController = viewController
        self.snp.makeConstraints { (make) in
            make.width.equalTo(viewController.view.snp.width).multipliedBy(0.5)
            make.centerX.equalTo(viewController.view.snp.centerX)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(viewController.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(viewController.bottomLayoutGuide.snp.bottom).offset(-10)
            }
            make.height.equalTo(30)
        }
        self.addTarget(self, action: #selector(self.handlePageControlEvent), for: .valueChanged)
    }
    
    func totalUnitPageDidChange(_ totalUnitPage: Int, in viewController: MediaBrowserViewController) {
        self.numberOfPages = viewController.totalUnitPage
        self.currentPage = viewController.currentPage
    }
    
    func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController) {
        self.currentPage = toIndex
    }
    
    func layout(in viewController: MediaBrowserViewController) {
        
    }
    
    func didScroll(to index: Int, in viewController: MediaBrowserViewController) {
        
    }
    
    @objc func handlePageControlEvent() {
        self.browserViewController?.browserView.setCurrentPage(self.currentPage, animated: true)
    }
    
    
}
