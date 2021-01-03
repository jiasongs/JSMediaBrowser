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

class ExampleViewController: UIViewController {
    
    var floatLayoutView: QMUIFloatLayoutView!
    var dataSource: Array<String> = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
        /// 设置全局Block
        MediaBrowserAppearance.appearance.addImageViewInZoomViewBlock = { (browserVC: MediaBrowserViewController, zoomImageView: ZoomImageView) -> UIImageView in
            return SDAnimatedImageView() // ImageView()
        }
        MediaBrowserAppearance.appearance.addWebImageMediatorBlock = { (browserVC: MediaBrowserViewController, sourceItem: SourceProtocol) -> WebImageMediatorProtocol in
            return DefaultWebImageMediator()
        }
        MediaBrowserAppearance.appearance.addToolViewsBlock = { (browserVC: MediaBrowserViewController) -> Array<UIView & ToolViewProtocol> in
            let pageControl: PageControl = PageControl()
            let shareControl: ShareControl = ShareControl()
            return [pageControl, shareControl]
        }
        MediaBrowserAppearance.appearance.configureCellBlock = { (browserVC: MediaBrowserViewController, cell: UICollectionViewCell, index: Int) in
            if let cell = cell as? BaseCell {
                if cell.pieProgressView?.tintColor != .white {
                    cell.pieProgressView?.tintColor = .white
                }
            }
        }
        MediaBrowserAppearance.appearance.willDisplayEmptyViewBlock = { (browserVC: MediaBrowserViewController, cell: UICollectionViewCell, emptyView: EmptyView, error: NSError) in
            emptyView.image = UIImage(named: "picture_fail")
            emptyView.title = "\(String(describing: error.localizedDescription))"
        }
        MediaBrowserAppearance.appearance.onLongPressBlock = { (browserVC: MediaBrowserViewController) in
            if let currentPage: Int = browserVC.browserView?.currentPage, var sourceItems = browserVC.sourceItems {
                sourceItems.remove(at: currentPage)
                browserVC.sourceItems = sourceItems
                browserVC.browserView?.reloadData()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        if let data = try? Data(contentsOf: NSURL.fileURL(withPath: Bundle.main.path(forResource: "data", ofType: "json") ?? "")) {
            var array = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? Array<String>
            if let data1 = Bundle.main.path(forResource: "data1", ofType: "jpg") {
                array?.append(URL(fileURLWithPath: data1).absoluteString)
            }
            if let data2 = Bundle.main.path(forResource: "data2", ofType: "gif") {
                array?.append(URL(fileURLWithPath: data2).absoluteString)
            }
            self.dataSource = array ?? []
        }
        self.floatLayoutView = QMUIFloatLayoutView()
        self.floatLayoutView!.itemMargins = UIEdgeInsets(top: QMUIHelper.pixelOne(), left: QMUIHelper.pixelOne(), bottom: 0, right: 0);
        for item: String in self.dataSource {
            let button = QMUIButton()
            //            button.layer.cornerRadius = 10;
            //            button.layer.masksToBounds = true;
            if item.contains("mp4") {
                button.setImage(self.getVideoFirstImage(with: URL(string: item)!), for: .normal)
            } else {
                button.sd_setImage(with: URL(string: item)!, for: .normal, completed: nil)
            }
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
        let oldSize: CGSize = self.floatLayoutView.bounds.size
        self.floatLayoutView!.frame = CGRect(x: margins.left, y: margins.top, width: contentWidth, height: QMUIViewSelfSizingHeight);
        /// 前后Bounds相等时, 也需要刷新下内部子视图的布局, 不然可能会有Bug
        if oldSize.equalTo(self.floatLayoutView.bounds.size) {
            self.floatLayoutView.setNeedsLayout()
            self.floatLayoutView.layoutIfNeeded()
        }
    }
    
    @objc func handleImageButtonEvent(sender: QMUIButton) -> Void {
        let browser: MediaBrowserViewController = MediaBrowserViewController()
        var sourceItems: Array<SourceProtocol> = [];
        for (index, urlString) in self.dataSource.enumerated() {
            if let button: QMUIButton = self.floatLayoutView.subviews[index] as? QMUIButton {
                if urlString.contains("mp4") {
                    let videoEntity = VideoEntity(sourceView: button, sourceRect: CGRect.zero, thumbImage: button.image(for: .normal))
                    videoEntity.videoUrl = URL(string: urlString)
                    sourceItems.append(videoEntity)
                } else {
                    let imageEntity = ImageEntity(sourceView: button, sourceRect: CGRect.zero, thumbImage: button.image(for: .normal))
                    imageEntity.imageUrl = URL(string: urlString)
                    imageEntity.sourceCornerRadius = button.layer.cornerRadius
                    sourceItems.append(imageEntity)
                }
            }
        }
        browser.sourceItems = sourceItems
        browser.browserView?.currentPage = self.floatLayoutView.subviews.firstIndex(of: sender) ?? 0
        browser.show(from: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func getVideoFirstImage(with url: URL) -> UIImage? {
        let asset: AVURLAsset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true;
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 1)
        var actualTime : CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 0)
        let cgImage: CGImage? = try? generator.copyCGImage(at: time, actualTime: &actualTime)
        if let cgImage = cgImage {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
}
