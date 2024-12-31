//
//  HomeViewController.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit
import QMUIKit
import SDWebImage
import Kingfisher
import SnapKit
import JSMediaBrowser
import Then

class HomeViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    lazy var dataSource: [String] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.extendedLayoutIncludesOpaqueBars = true
        
        SDWebImageManager.shared.imageCache.clear?(with: .all)
        
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearCache()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.view.addSubview(self.collectionView)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(HomePictureCell.self, forCellWithReuseIdentifier: "\(HomePictureCell.self)")
        
        /// 数据源
        guard let data = try? Data(contentsOf: NSURL.fileURL(withPath: Bundle.main.path(forResource: "data", ofType: "json") ?? "")) else {
            return
        }
        var array = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? [String]
        if let hdr = Bundle.main.path(forResource: "TestHDR1", ofType: "heic") {
            array?.append(URL(fileURLWithPath: hdr).absoluteString)
        }
        if let hdr = Bundle.main.path(forResource: "TestHDR2", ofType: "JPG") {
            array?.append(URL(fileURLWithPath: hdr).absoluteString)
        }
        if let hdr = Bundle.main.path(forResource: "TestHDR3", ofType: "JPG") {
            array?.append(URL(fileURLWithPath: hdr).absoluteString)
        }
        if let data = Bundle.main.path(forResource: "data1", ofType: "jpg") {
            array?.append(URL(fileURLWithPath: data).absoluteString)
        }
        if let data = Bundle.main.path(forResource: "data2", ofType: "gif") {
            array?.append(URL(fileURLWithPath: data).absoluteString)
        }
        if let data = Bundle.main.path(forResource: "data3", ofType: "jpg") {
            array?.append(URL(fileURLWithPath: data).absoluteString)
        }
        if let data = Bundle.main.path(forResource: "data4", ofType: "jpg") {
            array?.append(URL(fileURLWithPath: data).absoluteString)
        }
        self.dataSource = array ?? []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "图片/视频预览"
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
        let margin = QMUIHelper.isMac ? 60.0 : 24.0
        self.collectionView.qmui_initialContentInset = UIEdgeInsets(top: self.view.safeAreaInsets.top + 5,
                                                                    left: margin + self.view.safeAreaInsets.left,
                                                                    bottom: self.view.safeAreaInsets.bottom,
                                                                    right: margin + self.view.safeAreaInsets.right)
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.frame = self.view.bounds
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(HomePictureCell.self)", for: indexPath) as? HomePictureCell else {
            fatalError()
        }
        let item = self.dataSource[indexPath.item]
        if item.contains("mp4") {
            self.videoFirstImage(with: URL(string: item)!) { image in
                cell.imageView.image = image
            }
        } else {
            cell.imageView.sd_setImage(with: URL(string: item))
        }
        return cell
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interitemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let columnsCount = QMUIHelper.isMac ? 6.0 : 3.0
        let size = (collectionView.qmui_width - UIEdgeInsetsGetHorizontalValue(collectionView.adjustedContentInset) - (columnsCount - 1) * interitemSpacing) / columnsCount
        return CGSizeFloor(CGSize(width: size, height: size))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browserVC = JSMediaBrowserViewController()
        browserVC.dataSource = self.dataSource.map { urlString in
            var item: AssetItem
            if urlString.contains("mp4") {
                item = VideoItem(videoUrl: URL(string: urlString), thumbImage: nil)
            } else {
                item = ImageItem(imageUrl: URL(string: urlString), thumbImage: nil)
            }
            return item
        }
        browserVC.currentPage = indexPath.item
        browserVC.source = .init(sourceView: {[weak self] in
            guard let cell = self?.pictureCell(at: $0) else {
                return nil
            }
            return cell.imageView
        })
        browserVC.show(from: self, navigationController: QMUINavigationController(rootViewController: browserVC), animated: true)
    }
    
}

extension HomeViewController {
    
    private func pictureCell(at index: Int) -> HomePictureCell? {
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? HomePictureCell else {
            return nil
        }
        return cell
    }
    
    private func videoFirstImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTimeMakeWithSeconds(0, preferredTimescale: 1))]) { _, cgImage, _, _, error in
                DispatchQueue.main.async {
                    if let cgImage = cgImage {
                        completion(UIImage(cgImage: cgImage))
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
}

extension HomeViewController {
    
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
    
}
