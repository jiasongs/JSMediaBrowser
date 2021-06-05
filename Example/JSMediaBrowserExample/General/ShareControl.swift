//
//  ShareControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/26.
//

import UIKit
import JSCoreKit
import JSMediaBrowser
import SnapKit

class ShareControl: UIButton, ToolViewProtocol {
    
    weak var browserViewController: MediaBrowserViewController?
    
    func prepare(in viewController: MediaBrowserViewController) {
        self.browserViewController = viewController
        self.setTitle("分享", for: UIControl.State.normal)
        self.setTitleColor(.white, for: UIControl.State.normal)
        self.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.right.equalTo(viewController.view.snp.right).offset(-20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(viewController.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(viewController.bottomLayoutGuide.snp.bottom).offset(-10)
            }
        }
        self.addTarget(self, action: #selector(self.onPress), for: UIControl.Event.touchUpInside)
    }
    
    func layout(in viewController: MediaBrowserViewController) {
        
    }
    
    func totalUnitPageDidChange(_ totalUnitPage: Int, in viewController: MediaBrowserViewController) {
        
    }
    
    func willScrollHalf(fromIndex: Int, toIndex: Int, in viewController: MediaBrowserViewController) {
        
    }
    
    func didScroll(to index: Int, in viewController: MediaBrowserViewController) {
        
    }
    
    @objc func onPress() {
        let vc = UIViewController()
        vc.qmui_visibleStateDidChangeBlock = { (vc, state) in
            if state == .viewDidLoad {
                vc.view.backgroundColor = UIColor.white
            } else if state == .willAppear {
                vc.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
        self.browserViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

