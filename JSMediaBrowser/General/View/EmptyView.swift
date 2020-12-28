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
        imageView.backgroundColor = .gray
        return imageView
    }()
    @objc lazy open var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "显示错误"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    @objc lazy open var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "网络连接不畅， 建议重新刷新"
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    @objc lazy open var actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: UIControl.State.normal)
        button.setTitle("重试", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(self.handleAction(button:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = .blue
        return button
    }()
    
    @objc open var image: UIImage? {
        didSet {
            imageView.image = image
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
        let imageViewSize = CGSize(width: self.frame.width * 0.5, height: self.frame.width * 0.5)
        var titleSize = CGSize(width: self.frame.width * 0.7, height: 0)
        titleSize.height = titleLabel.sizeThatFits(titleSize).height
        var subtitleSize = CGSize(width: titleSize.width * 0.8, height: 0)
        subtitleSize.height = subtitleLabel.sizeThatFits(subtitleSize).height
        var buttonSize = CGSize(width: subtitleSize.width * 0.7, height: 0)
        buttonSize.height = actionButton.sizeThatFits(buttonSize).height
        let subviewsHeight = imageViewSize.height + titleSize.height + subtitleSize.height + buttonSize.height
        let margin: CGFloat = 10.0
        imageView.frame = CGRect(x: (self.frame.width - imageViewSize.width) / 2, y: (self.frame.height - subviewsHeight) / 2 - 40, width: imageViewSize.width, height: imageViewSize.height)
        titleLabel.frame = CGRect(origin: CGPoint(x: (self.frame.width - titleSize.width) / 2, y: imageView.frame.maxY + margin), size: titleSize)
        subtitleLabel.frame = CGRect(origin: CGPoint(x: (self.frame.width - subtitleSize.width) / 2, y: titleLabel.frame.maxY + margin), size: subtitleSize)
        actionButton.frame = CGRect(origin: CGPoint(x: (self.frame.width - buttonSize.width) / 2, y: subtitleLabel.frame.maxY + margin + 5), size: buttonSize)
    }
    
    @objc func handleAction(button: UIButton) -> Void {
        if let block = self.onPressAction {
            block(button)
        }
    }
    
}
