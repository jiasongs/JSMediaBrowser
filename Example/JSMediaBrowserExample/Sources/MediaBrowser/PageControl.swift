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

class PageControl: UIPageControl {
    
    weak var mediaBrowserVC: JSMediaBrowserViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(self.handlePageControlEvent), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }  
  
    @objc func handlePageControlEvent() {
        guard let mediaBrowserVC = self.mediaBrowserVC else {
            return
        }
        mediaBrowserVC.setCurrentPage(self.currentPage, animated: true)
    }
    
}
