//
//  PagingCollectionView.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

public protocol PagingCollectionViewGestureDelegate: AnyObject {
    
    func pagingCollectionView(_ pagingCollectionView: PagingCollectionView, shouldBegin gestureRecognizer: UIGestureRecognizer, originReturn value: Bool) -> Bool
    
    func pagingCollectionView(_ pagingCollectionView: PagingCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
}

public class PagingCollectionView: UICollectionView {
    
    public weak var gestureDelegate: PagingCollectionViewGestureDelegate?
    
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
        self.contentInsetAdjustmentBehavior = .never
    }
    
}

extension PagingCollectionView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureDelegate = self.gestureDelegate else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        
        return gestureDelegate.pagingCollectionView(self, shouldBegin: gestureRecognizer, originReturn: super.gestureRecognizerShouldBegin(gestureRecognizer))
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureDelegate = self.gestureDelegate else {
            return false
        }
        
        return gestureDelegate.pagingCollectionView(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
    }
    
}
