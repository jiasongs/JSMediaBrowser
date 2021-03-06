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
import Then

class ExampleViewController: UIViewController {
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()
    lazy var floatLayoutView: JSFloatLayoutView = {
        let view = JSFloatLayoutView()
        view.itemMargins = UIEdgeInsets(top: QMUIHelper.pixelOne, left: QMUIHelper.pixelOne, bottom: 0, right: 0);
        return view
    }()
    lazy var dataSource: Array<String> = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: nil)
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
            if let data3 = Bundle.main.path(forResource: "data3", ofType: "jpg") {
                array?.append(URL(fileURLWithPath: data3).absoluteString)
            }
            array = array?.filter { !$0.contains("mp4") }
            self.dataSource = array ?? []
        }
        self.view.addSubview(self.scrollView)
        for item: String in self.dataSource {
            let button = QMUIButton()
            let imageView = SDAnimatedImageView()
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            button.addSubview(imageView)
            imageView.snp.makeConstraints { (maker: ConstraintMaker) in
                maker.edges.equalTo(button)
            }
            if item.contains("mp4") {
                imageView.image = self.getVideoFirstImage(with: URL(string: item)!)
            } else {
                imageView.sd_setImage(with: URL(string: item))
            }
            button.addTarget(self, action: #selector(self.handleImageButtonEvent(sender:)), for: UIControl.Event.touchUpInside)
            self.floatLayoutView.addSubview(button)
        }
        self.scrollView.addSubview(floatLayoutView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "图片/视频预览"
        self.navigationController?.delegate = self
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let top = self.qmui_navigationBarMaxYInViewCoordinator
        let margins: UIEdgeInsets = UIEdgeInsets(top: top + 5, left: 24 + self.view.qmui_safeAreaInsets.left, bottom: 24, right: 24 + self.view.qmui_safeAreaInsets.right);
        let contentWidth: CGFloat = self.view.qmui_width - UIEdgeInsetsGetHorizontalValue(margins);
        let column: Int = self.view.qmui_width > 700 ? 8 : 3
        let horizontalValue: CGFloat = CGFloat((column - 1)) * UIEdgeInsetsGetHorizontalValue(self.floatLayoutView.itemMargins);
        let imgWith: CGFloat = contentWidth / CGFloat(column) - horizontalValue;
        self.floatLayoutView.minimumItemSize = CGSize(width: imgWith, height: imgWith);
        self.floatLayoutView.maximumItemSize = self.floatLayoutView.minimumItemSize;
        let oldSize: CGSize = self.floatLayoutView.bounds.size
        self.floatLayoutView.frame = CGRect(x: margins.left, y: margins.top, width: contentWidth, height: QMUIViewSelfSizingHeight);
        /// 前后Bounds相等时, 也需要刷新下内部子视图的布局, 不然可能会有Bug
        if oldSize.equalTo(self.floatLayoutView.bounds.size) {
            self.floatLayoutView.setNeedsLayout()
            self.floatLayoutView.layoutIfNeeded()
        }
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize = self.floatLayoutView.bounds.size
    }
    
    @objc func handleImageButtonEvent(sender: QMUIButton) -> Void {
        let browser: MediaBrowserViewController = MediaBrowserViewController()
        /// 配置
        browser.sourceViewDelegate = self
        browser.webImageMediator = SDWebImageMediator()
        browser.additionalViews = [PageControl(), ShareControl()]
        browser.imageViewForZoomView = { (_, _) in
            return SDAnimatedImageView().then { $0.autoPlayAnimatedImage = false }
        }
        browser.willDisplayEmptyView = { (_, _, emptyView: EmptyView, error: NSError) in
            emptyView.image = UIImage(named: "picture_fail")
            emptyView.title = "\(String(describing: error.localizedDescription))"
        }
        
        var sourceItems: Array<SourceProtocol> = [];
        for (_, urlString) in self.dataSource.enumerated() {
            if urlString.contains("mp4") {
                let videoEntity = VideoEntity(sourceRect: CGRect.zero, thumbImage: nil, videoUrl: URL(string: urlString))
                sourceItems.append(videoEntity)
            } else {
                let imageEntity = ImageEntity(sourceRect: CGRect.zero, thumbImage: nil, imageUrl: URL(string: urlString))
                sourceItems.append(imageEntity)
            }
        }
        browser.sourceItems = sourceItems
        browser.currentPage = self.floatLayoutView.subviews.firstIndex(of: sender) ?? 0
        
        browser.show(from: self, navigationController: NavigationController(rootViewController: browser))
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
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

extension ExampleViewController: MediaBrowserViewControllerSourceViewDelegate {
    
    func sourceViewForPageAtIndex(_ index: Int) -> UIView? {
        return self.floatLayoutView.subviews[index]
    }
    
    func sourceViewCornerRadiusForPageAtIndex(_ index: Int) -> CGFloat {
        return 0
    }
    
}

extension ExampleViewController: UINavigationControllerDelegate {
    
}
