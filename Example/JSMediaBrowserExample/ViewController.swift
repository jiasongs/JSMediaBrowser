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
    var dataSource: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
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
//            button.layer.cornerRadius = 10;
//            button.layer.masksToBounds = true;
            button.sd_setImage(with: URL.init(string: item)!, for: UIControl.State.normal, completed: nil)
            button.imageView?.contentMode = .scaleAspectFill
            button.addTarget(self, action: #selector(self.handleImageButtonEvent(sender:)), for: UIControl.Event.touchUpInside)
            self.floatLayoutView!.addSubview(button)
        }
        self.view.addSubview(floatLayoutView!)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margins: UIEdgeInsets = UIEdgeInsets.init(top: 70 + self.qmui_navigationBarMaxYInViewCoordinator, left: 24 + self.view.qmui_safeAreaInsets.left, bottom: 24, right: 24 + self.view.qmui_safeAreaInsets.right);
        let contentWidth: CGFloat = self.view.qmui_width - UIEdgeInsetsGetHorizontalValue(margins);
        let column: Int = self.view.qmui_width > 700 ? 8 : 3
        let horizontalValue: CGFloat = CGFloat((column - 1)) * UIEdgeInsetsGetHorizontalValue(self.floatLayoutView.itemMargins);
        let imgWith: CGFloat = contentWidth / CGFloat(column) - horizontalValue;
        self.floatLayoutView!.minimumItemSize = CGSize.init(width: imgWith, height: imgWith);
        self.floatLayoutView!.maximumItemSize = self.floatLayoutView!.minimumItemSize;
        self.floatLayoutView!.frame = CGRect.init(x: margins.left, y: margins.top, width: contentWidth, height: QMUIViewSelfSizingHeight);
    }
    
    @objc func handleImageButtonEvent(sender: QMUIButton) -> Void {
        let browser: MediaBrowserViewController = MediaBrowserViewController.init()
        browser.browserView?.currentMediaIndex = self.floatLayoutView.subviews.firstIndex(of: sender) ?? 0
        var sourceItems: Array<ImageEntity> = [];
        for (index, urlString) in self.dataSource.enumerated() {
            let imageEntity = ImageEntity.init(sourceView: self.floatLayoutView.subviews[index], sourceRect: CGRect.zero, thumbImage: nil)
            imageEntity.imageUrl = URL.init(string: urlString)
            imageEntity.sourceCornerRadius = self.floatLayoutView.subviews[index].layer.cornerRadius
            sourceItems.append(imageEntity)
         }
        browser.sourceItems = sourceItems
        browser.show(from: self, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}
