//
//  EmptyView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/28.
//

import UIKit

public class EmptyView: UIView {
    
    public var image: UIImage? {
        didSet {
            self.imageView.image = self.image
            self.setNeedsLayout()
        }
    }
    
    public var imageViewSize: CGSize = CGSize.zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var title: String? {
        didSet {
            self.titleLabel.text = self.title
            self.setNeedsLayout()
        }
    }
    
    public var subtitle: String? {
        didSet {
            self.subtitleLabel.text = self.subtitle
            self.setNeedsLayout()
        }
    }
    
    public var actionTitle: String? {
        didSet {
            self.actionButton.setTitle(self.actionTitle, for: UIControl.State.normal)
            self.actionButton.setTitle(self.actionTitle, for: UIControl.State.selected)
            self.actionButton.setTitle(self.actionTitle, for: UIControl.State.highlighted)
            self.setNeedsLayout()
        }
    }
    
    public var onPressAction: ((UIButton) -> Void)?
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    fileprivate lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    fileprivate lazy var actionButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.white, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(self.handleAction(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    public func didInitialize() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.actionButton)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        var imageSize: CGSize = self.imageViewSize
        if imageSize == CGSize.zero {
            let width = min(self.frame.width * 0.4, 120)
            imageSize = CGSize(width: width, height: width)
        }
        if self.imageView.image == nil {
            imageSize = CGSize.zero
        }
        var titleSize = CGSize(width: min(self.frame.width * 0.6, 280), height: 0)
        if let count = self.titleLabel.text?.count, count > 0 {
            titleSize.height = self.titleLabel.sizeThatFits(titleSize).height
        }
        var subtitleSize = CGSize(width: min(self.frame.width * 0.75, 350), height: 0)
        if let count = self.subtitleLabel.text?.count, count > 0 {
            subtitleSize.height = self.subtitleLabel.sizeThatFits(subtitleSize).height
        }
        var buttonSize = CGSize(width: subtitleSize.width * 0.6, height: 0)
        if let count = self.actionButton.titleLabel?.text?.count, count > 0 {
            buttonSize.height = self.actionButton.sizeThatFits(buttonSize).height
        }
        let margin: CGFloat = 12.0
        let buttonMarginTop: CGFloat = 15.0
        let subviewsHeight = imageSize.height + titleSize.height + subtitleSize.height + buttonSize.height + margin * 2 + buttonMarginTop
        self.imageView.frame = CGRect(x: (self.frame.width - imageSize.width) / 2, y: (self.frame.height - subviewsHeight) / 2, width: imageSize.width, height: imageSize.height)
        self.titleLabel.frame = CGRect(origin: CGPoint(x: (self.frame.width - titleSize.width) / 2, y: self.imageView.frame.maxY + margin), size: titleSize)
        self.subtitleLabel.frame = CGRect(origin: CGPoint(x: (self.frame.width - subtitleSize.width) / 2, y: self.titleLabel.frame.maxY + margin), size: subtitleSize)
        self.actionButton.frame = CGRect(origin: CGPoint(x: (self.frame.width - buttonSize.width) / 2, y: self.subtitleLabel.frame.maxY + buttonMarginTop), size: buttonSize)
        
        self.imageView.isHidden = imageSize == CGSize.zero
        self.titleLabel.isHidden = titleSize.height == 0
        self.subtitleLabel.isHidden = subtitleSize.height == 0
        self.actionButton.isHidden = buttonSize.height == 0
    }
    
    @objc func handleAction(button: UIButton) {
        self.onPressAction?(button)
    }
    
}
