//
//  EmptyView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/28.
//

import UIKit

@objc open class EmptyView: UIView {
    
    @objc lazy open var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    @objc lazy open var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    @objc lazy open var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    @objc lazy open var actionButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.white, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(self.handleAction(button:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    @objc open var image: UIImage? {
        didSet {
            imageView.image = image
            self.setNeedsLayout()
        }
    }
    @objc open var imageViewSize: CGSize = CGSize.zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    @objc open var title: String? {
        didSet {
            titleLabel.text = title
            self.setNeedsLayout()
        }
    }
    @objc open var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
            self.setNeedsLayout()
        }
    }
    @objc open var actionTitle: String? {
        didSet {
            actionButton.setTitle(actionTitle, for: UIControl.State.normal)
            self.setNeedsLayout()
        }
    }
    
    @objc open var onPressAction: ((UIButton) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.actionButton)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        var imageSize: CGSize = self.imageViewSize
        if imageSize.equalTo(CGSize.zero) {
            imageSize = CGSize(width: min(self.frame.width * 0.5, 150), height: min(self.frame.width * 0.5, 150))
        }
        if self.imageView.image == nil {
            imageSize = CGSize.zero
        }
        var titleSize = CGSize(width: min(self.frame.width * 0.6, 200), height: 0)
        if let count = titleLabel.text?.count, count > 0 {
            titleSize.height = titleLabel.sizeThatFits(titleSize).height
        }
        var subtitleSize = CGSize(width: min(self.frame.width * 0.8, 220), height: 0)
        if let count = subtitleLabel.text?.count, count > 0 {
            subtitleSize.height = subtitleLabel.sizeThatFits(subtitleSize).height
        }
        var buttonSize = CGSize(width: subtitleSize.width * 0.6, height: 0)
        if let count = actionButton.titleLabel?.text?.count, count > 0 {
            buttonSize.height = actionButton.sizeThatFits(buttonSize).height
        }
        let margin: CGFloat = 12.0
        let buttonMarginTop: CGFloat = 15.0
        let subviewsHeight = imageSize.height + titleSize.height + subtitleSize.height + buttonSize.height + margin * 2 + buttonMarginTop
        imageView.frame = CGRect(x: (self.frame.width - imageSize.width) / 2, y: (self.frame.height - subviewsHeight) / 2, width: imageSize.width, height: imageSize.height)
        titleLabel.frame = CGRect(origin: CGPoint(x: (self.frame.width - titleSize.width) / 2, y: imageView.frame.maxY + margin), size: titleSize)
        subtitleLabel.frame = CGRect(origin: CGPoint(x: (self.frame.width - subtitleSize.width) / 2, y: titleLabel.frame.maxY + margin), size: subtitleSize)
        actionButton.frame = CGRect(origin: CGPoint(x: (self.frame.width - buttonSize.width) / 2, y: subtitleLabel.frame.maxY + buttonMarginTop), size: buttonSize)
        
        imageView.isHidden = imageSize.equalTo(CGSize.zero)
        titleLabel.isHidden = titleSize.height == 0
        subtitleLabel.isHidden = subtitleSize.height == 0
        actionButton.isHidden = buttonSize.height == 0
    }
    
    @objc func handleAction(button: UIButton) -> Void {
        if let block = self.onPressAction {
            block(button)
        }
    }
    
}
