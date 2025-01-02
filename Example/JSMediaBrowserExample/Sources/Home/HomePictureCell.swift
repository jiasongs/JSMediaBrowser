//
//  HomePictureCell.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2023/1/6.
//  Copyright © 2023 jiasong. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

class HomePictureCell: UICollectionViewCell {
    
    lazy var imageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (maker: ConstraintMaker) in
            maker.edges.equalTo(self.contentView)
        }
    }
    
    @available(*, unavailable, message: "use init()")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
