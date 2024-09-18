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
        self.alwaysBounceVertical = false
        self.alwaysBounceHorizontal = true
        self.scrollsToTop = false
        self.delaysContentTouches = false
        self.decelerationRate = .fast
        self.isPagingEnabled = true
        self.contentInsetAdjustmentBehavior = .never
    }
    
}

extension PagingCollectionView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let _ = touch.view as? UISlider {
            return false
        } else {
            return true
        }
    }
    
}
