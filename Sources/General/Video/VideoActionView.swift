//
//  VideoActionView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/4.
//

import UIKit

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
    }
    
}

extension VideoActionView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
