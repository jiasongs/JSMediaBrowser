//
//  VideoCell.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/3.
//

import UIKit
import JSCoreKit

open class VideoCell: BaseCell {
    
    @objc open var videoPlayerView: VideoPlayerView?
    @objc open var videoActionView: VideoActionView?
    @objc open var closeButton: UIButton?
    @objc open var onPressCloseBlock: ((UICollectionViewCell) -> Void)?
    open var isShowed: Bool {
        if let videoActionView = self.videoActionView {
            return !videoActionView.isHidden
        }
        return false
    }
    
    open override func didInitialize() -> Void {
        super.didInitialize()
        self.videoPlayerView = VideoPlayerView()
        self.contentView.addSubview(self.videoPlayerView!)
        contentView.sendSubviewToBack(self.videoPlayerView!)
        
        self.videoActionView = VideoActionView()
        contentView.addSubview(self.videoActionView!)
        
        self.closeButton = UIButton(type: .custom)
        self.closeButton?.setTitle("关闭", for: .normal)
        self.closeButton?.addTarget(self, action: #selector(self.onPressClose), for: .touchUpInside)
        contentView.addSubview(self.closeButton!)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTapGesture))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        contentView.addGestureRecognizer(singleTapGesture)
        
        self.hideForTool(animated: false)
    }
    
    open override func prepareForReuse() -> Void {
        super.prepareForReuse()
        self.videoPlayerView?.reset()
        self.videoPlayerView?.thumbImage = nil
        self.videoPlayerView?.delegate = nil
        self.pieProgressView?.isHidden = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.videoPlayerView?.js_frameApplyTransform = self.contentView.bounds
        let margin: CGFloat = 10.0
        let height: CGFloat = 40
        let bottom = JSCoreHelper.isNotchedScreen() ? JSCoreHelper.safeAreaInsetsForDeviceWithNotch().bottom : 20
        self.videoActionView?.js_frameApplyTransform = CGRect(x: margin, y: self.contentView.bounds.height - height - bottom - 40, width: self.contentView.bounds.width - margin * 2, height: height)
        self.closeButton?.js_frameApplyTransform = CGRect(x: margin, y: JSCoreHelper.statusBarHeightConstant() + 10, width: 100, height: 25)
    }
    
    @objc public override func updateCell(loaderEntity: LoaderProtocol, at index: Int) {
        super.updateCell(loaderEntity: loaderEntity, at: index)
        if let sourceItem = loaderEntity.sourceItem as? VideoSourceProtocol {
            self.videoPlayerView?.delegate = self
            self.videoPlayerView?.thumbImage = sourceItem.thumbImage
            self.videoPlayerView?.url = sourceItem.videoUrl
        }
    }
    
    @objc func handleSingleTapGesture() {
        if self.isShowed {
            self.hideForTool()
        } else {
            self.showForTool()
        }
    }
    
    @objc func onPressClose() {
        if let block = onPressCloseBlock {
            block(self)
        }
    }
    
    @objc open func showForTool(animated: Bool = true) {
        self.videoActionView?.isHidden = false
        self.closeButton?.isHidden = false
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: AnimationOptionsCurveOut) {
                self.videoActionView?.alpha = 1.0
                self.closeButton?.alpha = 1.0
            } completion: { (finshed) in
                
            }
        } else {
            self.videoActionView?.alpha = 1.0
            self.closeButton?.alpha = 1.0
        }
    }
    
    @objc open func hideForTool(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: AnimationOptionsCurveOut) {
                self.videoActionView?.alpha = 0.0
                self.closeButton?.alpha = 0.0
            } completion: { (finshed) in
                self.videoActionView?.isHidden = true
                self.closeButton?.isHidden = true
            }
        } else {
            self.videoActionView?.alpha = 0.0
            self.closeButton?.alpha = 0.0
            self.videoActionView?.isHidden = true
            self.closeButton?.isHidden = true
        }
    }
    
}

extension VideoCell: VideoPlayerViewDelegate {
    
    public func videoPlayerViewDidReadyForDisplay(_ videoPlayerView: VideoPlayerView) {
        self.didCompleted(with: nil, cancelled: false, finished: true)
    }
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, progress currentTime: CGFloat, totalDuration: CGFloat) {
        
    }
    
    public func videoPlayerViewDidPlayToEndTime(_ videoPlayerView: VideoPlayerView) {
        
    }
    
    public func videoPlayerView(_ videoPlayerView: VideoPlayerView, didFailed error: NSError?) {
        self.didCompleted(with: error, cancelled: false, finished: true)
    }
    
}
