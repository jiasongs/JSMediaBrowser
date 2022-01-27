//
//  PagingCollectionView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public class PagingCollectionView: UICollectionView {
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    public func didInitialize() {
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.scrollsToTop = false
        self.delaysContentTouches = false
        self.decelerationRate = .fast
        self.isPagingEnabled = true
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
    }
    
}
