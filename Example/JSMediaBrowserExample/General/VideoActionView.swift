//
//  VideoActionView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/4.
//

import UIKit
import JSMediaBrowser

@objc open class VideoActionView: UIView {
    
    var playButton: UIButton?
    var currentTimeLabel: UILabel?
    var totalDurationLabel: UILabel?
    var slider: SliderView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5;
        self.clipsToBounds = true;
        self.backgroundColor = .red
        
        self.playButton = UIButton(type: .custom)
        self.playButton?.setTitle("播放", for: .normal)
        self.addSubview(self.playButton!)
        
        self.currentTimeLabel = UILabel()
        self.addSubview(self.currentTimeLabel!)
        
        self.totalDurationLabel = UILabel()
        self.addSubview(self.totalDurationLabel!)
        
        self.slider = SliderView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
//        self.videoActionView = VideoActionView()
//        contentView.addSubview(self.videoActionView!)
//        
//        self.closeButton = UIButton(type: .custom)
//        self.closeButton?.setTitle("关闭", for: .normal)
//        self.closeButton?.addTarget(self, action: #selector(self.onPressClose), for: .touchUpInside)
//        contentView.addSubview(self.closeButton!)
//        
//        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTapGesture))
//        singleTapGesture.numberOfTapsRequired = 1
//        singleTapGesture.numberOfTouchesRequired = 1
//        contentView.addGestureRecognizer(singleTapGesture)
//        
//        self.hideForTool(animated: false)
        
//        @objc func handleSingleTapGesture() {
//            if self.isShowed {
//                self.hideForTool()
//            } else {
//                self.showForTool()
//            }
//        }
//        
//        @objc func onPressClose() {
//            if let block = onPressCloseBlock {
//                block(self)
//            }
//        }
//        
//        @objc open func showForTool(animated: Bool = true) {
//            self.videoActionView?.isHidden = false
//            self.closeButton?.isHidden = false
//            if animated {
//                UIView.animate(withDuration: 0.25, delay: 0, options: AnimationOptionsCurveOut) {
//                    self.videoActionView?.alpha = 1.0
//                    self.closeButton?.alpha = 1.0
//                } completion: { (finshed) in
//                    
//                }
//            } else {
//                self.videoActionView?.alpha = 1.0
//                self.closeButton?.alpha = 1.0
//            }
//        }
//        
//        @objc open func hideForTool(animated: Bool = true) {
//            if animated {
//                UIView.animate(withDuration: 0.25, delay: 0, options: AnimationOptionsCurveOut) {
//                    self.videoActionView?.alpha = 0.0
//                    self.closeButton?.alpha = 0.0
//                } completion: { (finshed) in
//                    self.videoActionView?.isHidden = true
//                    self.closeButton?.isHidden = true
//                }
//            } else {
//                self.videoActionView?.alpha = 0.0
//                self.closeButton?.alpha = 0.0
//                self.videoActionView?.isHidden = true
//                self.closeButton?.isHidden = true
//            }
//        }
    }
    
}

extension VideoActionView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
