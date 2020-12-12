//
//  ViewController.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import QMUIKit
import SDWebImage
import SnapKit

class ViewController: UIViewController {
    
    var floatLayoutView: QMUIFloatLayoutView!
    var browser: MediaBrowserView!
    var dataSource: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = ["https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1466376595,3460773628&fm=26&gp=0.jpg",
                           "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=643903962,2695937018&fm=26&gp=0.jpg",
                           "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3121164654,816590068&fm=26&gp=0.jpg",
                           "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=622096340,3782403238&fm=26&gp=0.jpg",
                           "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=349365238,2569710698&fm=26&gp=0.jpg",
                           "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1566929321,2427730641&fm=26&gp=0.jpg",
                           "https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1607418626&di=8c9d107764f8873ca1f22997094abeac&src=http://b-ssl.duitang.com/uploads/item/201807/13/20180713120020_umtgg.thumb.700_0.jpg"]
        self.floatLayoutView = QMUIFloatLayoutView.init()
        self.floatLayoutView!.itemMargins = UIEdgeInsets.init(top: QMUIHelper.pixelOne(), left: QMUIHelper.pixelOne(), bottom: 0, right: 0);
        for item: String in self.dataSource {
            let button = QMUIButton.init()
            button.sd_setImage(with: URL.init(string: item)!, for: UIControl.State.normal, completed: nil)
            button.imageView?.contentMode = .scaleAspectFill
            button.addTarget(self, action: #selector(self.handleImageButtonEvent), for: UIControl.Event.touchUpOutside)
            self.floatLayoutView!.addSubview(button)
        }
        self.view.addSubview(floatLayoutView!)
        floatLayoutView.isHidden = true;
        
        self.browser = MediaBrowserView.init()
        self.browser!.delegate = self;
        self.browser!.dataSource = self;
        self.browser!.gestureDelegate = self
        self.browser!.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        self.view.addSubview(self.browser!)
        
        var margin: CGFloat = 0;
        if (TARGET_OS_MACCATALYST != 0) {
            margin = 100;
        }
        self.browser.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(margin)
            make.top.equalTo(self.view.snp.top).offset(margin)
            make.right.equalTo(self.view.snp.right).offset(-margin)
            make.bottom.equalTo(self.view.snp.bottom).offset(-margin)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let margins: UIEdgeInsets = UIEdgeInsets.init(top: QMUIHelper.safeAreaInsetsForDeviceWithNotch().top + self.qmui_navigationBarMaxYInViewCoordinator, left: 24 + self.view.qmui_safeAreaInsets.left, bottom: 24, right: 24 + self.view.qmui_safeAreaInsets.right);
        let contentWidth: CGFloat = self.view.qmui_width - UIEdgeInsetsGetHorizontalValue(margins);
        let column: Int = 3
        let horizontalValue: CGFloat = CGFloat((column - 1)) * UIEdgeInsetsGetHorizontalValue(self.floatLayoutView.itemMargins);
        let imgWith: CGFloat = contentWidth / CGFloat(column) - horizontalValue;
        self.floatLayoutView!.minimumItemSize = CGSize.init(width: imgWith, height: imgWith);
        self.floatLayoutView!.maximumItemSize = self.floatLayoutView!.minimumItemSize;
        self.floatLayoutView!.frame = CGRect.init(x: margins.left, y: margins.top, width: contentWidth, height: QMUIViewSelfSizingHeight);
    }
    
    @objc func handleImageButtonEvent() -> Void {
        
    }
    
}

extension ViewController: MediaBrowserViewDataSource {
    
    public func numberOfMediaItemsInBrowserView(_ browserView: MediaBrowserView) -> Int {
        return self.dataSource.count
    }
    
    public func mediaBrowserView(_ browserView: MediaBrowserView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.dataSource[indexPath.item]
        let cell: ImageCollectionViewCell = self.browser.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.zoomImageView.sd_internalSetImage(with: URL.init(string: item), placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), context: nil, setImageBlock: nil, progress: nil) { (image, data, eror, type, finshed, url) in
            cell.zoomImageView.image = image;
        }
        return cell
    }
    
}

extension ViewController: MediaBrowserViewDelegate {
    
    private func mediaBrowserView(_ browserView: MediaBrowserView, willDisplay cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.zoomImageView.revertZooming()
    }
    
    private func mediaBrowserView(_ browserView: MediaBrowserView, didEndDisplaying cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.zoomImageView.revertZooming()
    }
    
}

extension ViewController: MediaBrowserViewGestureDelegate {
    
    func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, singleTouch gestureRecognizer: UITapGestureRecognizer) {
        QMUITips.show(withText: "单击")
    }
    
    @objc func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, doubleTouch gestureRecognizer: UITapGestureRecognizer) {
        QMUITips.show(withText: "双击")
        let zoomImageView = (mediaBrowserView.currentMidiaCell as! ImageCollectionViewCell).zoomImageView
        zoomImageView?.zoom(from: gestureRecognizer, animated: true)
    }
    
    @objc func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, longPress gestureRecognizer: UILongPressGestureRecognizer) {
        QMUITips.show(withText: "长按")
    }
    
    @objc func mediaBrowserView(_ mediaBrowserView: MediaBrowserView, dismissing gestureRecognizer: UIPanGestureRecognizer, verticalDistance: CGFloat) {
        if gestureRecognizer.state == .ended {
            if (verticalDistance > self.browser.bounds.height / 2 / 3) {
                /// dissmiss
                mediaBrowserView.resetDismissingGesture()
            } else {
                mediaBrowserView.resetDismissingGesture()
            }
        }
    }
    
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    var zoomImageView: ZoomImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        zoomImageView = ZoomImageView.init()
        contentView.addSubview(zoomImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        zoomImageView.js_frameApplyTransform = self.contentView.bounds
    }
    
}

