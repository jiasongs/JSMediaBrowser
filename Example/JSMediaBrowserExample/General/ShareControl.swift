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

@objc class ShareControl: UIButton, ToolViewProtocol {
    
    weak var browserViewController: MediaBrowserViewController?
    
    func didAddToSuperview(in viewController: MediaBrowserViewController) {
        self.browserViewController = viewController
        self.setTitle("分享", for: UIControl.State.normal)
        self.setTitleColor(.white, for: UIControl.State.normal)
        self.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.right.equalTo(viewController.view.snp.right).offset(-20)
            make.bottom.equalTo(viewController.view.snp.bottom)
        }
        self.addTarget(self, action: #selector(self.onPress), for: UIControl.Event.touchUpInside)
    }
    
    func didLayoutSubviews(in viewController: MediaBrowserViewController) {
        let bottom = JSCoreHelper.isNotchedScreen ? viewController.view.qmui_safeAreaInsets.bottom : 20
        self.snp.updateConstraints { (make) in
            make.bottom.equalTo(viewController.view.snp.bottom).offset(-bottom)
        }
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

