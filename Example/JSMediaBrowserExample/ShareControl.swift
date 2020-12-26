//
//  ShareControl.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/26.
//

import UIKit
import JSCoreKit
import JSMediaBrowser

class ShareControl: UIButton, ToolViewProtocol {
    
    weak var browserViewController: MediaBrowserViewController?
    
    func sourceItemsDidChange(for browserViewController: MediaBrowserViewController) {
        
    }
    
    func viewDidLoad(for browserViewController: MediaBrowserViewController) {
        self.browserViewController = browserViewController
        self.setTitle("分享", for: UIControl.State.normal)
        self.setTitleColor(.white, for: UIControl.State.normal)
        let bottom = JSCoreHelper.isNotchedScreen() ? JSCoreHelper.safeAreaInsetsForDeviceWithNotch().bottom : 20
        self.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.right.equalTo(browserViewController.view.snp.right).offset(-20)
            make.bottom.equalTo(browserViewController.view.snp.bottom).offset(-bottom)
        }
        self.addTarget(self, action: #selector(self.onPress), for: UIControl.Event.touchUpInside)
    }
    
    @objc func onPress() {
       let alertVC = UIAlertController(title: "提示", message: "分享", preferredStyle: UIAlertController.Style.alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (action) in
            
        }))
        self.browserViewController?.present(alertVC, animated: true, completion: nil)
    }
    
}

