//
//  MediaBrowserViewController.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

import UIKit

class MediaBrowserViewController: UIViewController {
    
    @objc open var browserView: MediaBrowserView?
    @objc open var sourceItems: Array<String> = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.didInitialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    func didInitialize() -> Void {
        browserView = MediaBrowserView.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let browserView = self.browserView {
            browserView.delegate = self;
            browserView.dataSource = self;
            self.view.addSubview(browserView)
        }
    }
    
}

extension MediaBrowserViewController: MediaBrowserViewDelegate {
    
}

extension MediaBrowserViewController: MediaBrowserViewDataSource {
    
    func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int {
        return 0
    }
    
    func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell.init()
    }
    
}
