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
import JSMediaBrowser

class ViewController: UIViewController {
    
    var floatLayoutView: QMUIFloatLayoutView!
    var dataSource: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
        self.view.backgroundColor = .black
        if let data = try? Data(contentsOf: NSURL.fileURL(withPath: Bundle.main.path(forResource: "data", ofType: "json") ?? "")) {
            let array = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? Array<String>
            self.dataSource = array ?? []
        }
        self.floatLayoutView = QMUIFloatLayoutView()
        self.floatLayoutView!.itemMargins = UIEdgeInsets(top: QMUIHelper.pixelOne(), left: QMUIHelper.pixelOne(), bottom: 0, right: 0);
        for item: String in self.dataSource {
            let button = QMUIButton()
            //            button.layer.cornerRadius = 10;
            //            button.layer.masksToBounds = true;
            button.sd_setImage(with: URL(string: item)!, for: UIControl.State.normal, completed: nil)
            button.imageView?.contentMode = .scaleAspectFill
            button.addTarget(self, action: #selector(self.handleImageButtonEvent(sender:)), for: UIControl.Event.touchUpInside)
            self.floatLayoutView!.addSubview(button)
        }
        self.view.addSubview(floatLayoutView!)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let margins: UIEdgeInsets = UIEdgeInsets(top: 70 + self.qmui_navigationBarMaxYInViewCoordinator, left: 24 + self.view.qmui_safeAreaInsets.left, bottom: 24, right: 24 + self.view.qmui_safeAreaInsets.right);
        let contentWidth: CGFloat = self.view.qmui_width - UIEdgeInsetsGetHorizontalValue(margins);
        let column: Int = self.view.qmui_width > 700 ? 8 : 3
        let horizontalValue: CGFloat = CGFloat((column - 1)) * UIEdgeInsetsGetHorizontalValue(self.floatLayoutView.itemMargins);
        let imgWith: CGFloat = contentWidth / CGFloat(column) - horizontalValue;
        self.floatLayoutView!.minimumItemSize = CGSize(width: imgWith, height: imgWith);
        self.floatLayoutView!.maximumItemSize = self.floatLayoutView!.minimumItemSize;
        self.floatLayoutView!.frame = CGRect(x: margins.left, y: margins.top, width: contentWidth, height: QMUIViewSelfSizingHeight);
    }
    
    @objc func handleImageButtonEvent(sender: QMUIButton) -> Void {
        let browser: MediaBrowserViewController = MediaBrowserViewController()
        browser.buildWebImageMediatorBlock = { (browserVC: MediaBrowserViewController, sourceItem: SourceProtocol) -> WebImageMediatorProtocol in
            return DefaultWebImageMediator()
        }
        browser.browserView?.currentMediaIndex = self.floatLayoutView.subviews.firstIndex(of: sender) ?? 0
        var sourceItems: Array<ImageEntity> = [];
        for (index, urlString) in self.dataSource.enumerated() {
            if let button: QMUIButton = self.floatLayoutView.subviews[index] as? QMUIButton {
                let imageEntity = ImageEntity(sourceView: button, sourceRect: CGRect.zero, thumbImage: button.image(for: .normal))
                imageEntity.imageUrl = URL(string: urlString)
                imageEntity.sourceCornerRadius = button.layer.cornerRadius
                sourceItems.append(imageEntity)
            }
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
