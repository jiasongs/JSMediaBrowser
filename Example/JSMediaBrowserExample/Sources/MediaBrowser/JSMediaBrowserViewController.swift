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
import Kingfisher

public struct ImageItem: ImageAssetItem {
    
    public var thumbImage: UIImage?
    
    public var image: UIImage?
    public var imageUrl: URL?
    
    public init(image: UIImage? = nil, imageUrl: URL? = nil, thumbImage: UIImage? = nil) {
        self.image = image
        self.imageUrl = imageUrl
        self.thumbImage = thumbImage
    }
    
}

public struct VideoItem: VideoAssetItem {
    
    public var thumbImage: UIImage?
    
    public var videoUrl: URL?
    public var videoAsset: AVAsset?
    
    public init(videoUrl: URL? = nil, videoAsset: AVAsset? = nil, thumbImage: UIImage? = nil) {
        self.videoUrl = videoUrl
        self.videoAsset = videoAsset
        self.thumbImage = thumbImage
    }
    
}

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
    
    init() {
        let configuration = MediaBrowserViewControllerConfiguration(
            webImageMediator: { _ in
                // KFWebImageMediator()
                return SDWebImageMediator(context: [.animatedImageClass: SDAnimatedImage.self])
            },
            zoomImageViewModifier: { _ in
                // KFZoomImageViewModifier()
                return SDZoomImageViewModifier()
            })
        super.init(configuration: configuration)
        
        self.eventHandler = DefaultMediaBrowserViewControllerEventHandler(
            willReloadData: { [weak self] _ in
                guard let self = self else { return }
                self.updatePageControl()
            },
            willDisplayEmptyView: { emptyView, _, _ in
                emptyView.image = UIImage(named: "img_fail")
            },
            willScrollHalf: { [weak self] in
                guard let self = self else { return }
                self.updatePageControl(for: $1)
            },
            didLongPressTouch: {
                QMUITips.show(withText: "长按")
            }
        )
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
    }
    
}

extension JSMediaBrowserViewController {
    
    func updatePageControl(for index: Int? = nil) {
        self.pageControl.numberOfPages = self.totalUnitPage
        self.pageControl.currentPage = index ?? self.currentPage
    }
    
}
