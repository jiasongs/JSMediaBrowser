//
//  PagingLayout.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

open class PagingLayout: UICollectionViewFlowLayout {
    
    open var pageSpacing: CGFloat = 10
    
    public override init() {
        super.init()
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    open func didInitialize() {
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.scrollDirection = .horizontal
        self.sectionInset = .zero
    }
    
}

extension PagingLayout {
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var resultAttributes: [UICollectionViewLayoutAttributes] = []
        let originalAttributes: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) ?? []
        for originalAttributesItem in originalAttributes {
            if let attributesItem = self.layoutAttributesForItem(at: originalAttributesItem.indexPath), attributesItem.frame.intersects(rect) {
                resultAttributes.append(attributesItem)
            }
        }
        return resultAttributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = self.collectionView else {
            return nil
        }
        if let attributesItem = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes {
            let halfWidth: CGFloat = attributesItem.size.width / 2.0
            let centerX: CGFloat = collectionView.contentOffset.x + halfWidth
            attributesItem.center = CGPoint(x: attributesItem.center.x + (attributesItem.center.x - centerX) / halfWidth * self.pageSpacing / 2,
                                            y: attributesItem.center.y)
            return attributesItem
        } else {
            return nil
        }
    }
    
}

extension PagingLayout {
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context: UICollectionViewLayoutInvalidationContext = super.invalidationContext(forBoundsChange: newBounds)
        if let flowContext = context as? UICollectionViewFlowLayoutInvalidationContext {
            flowContext.invalidateFlowLayoutDelegateMetrics = true
            flowContext.invalidateFlowLayoutAttributes = true
        }
        return context
    }
    
}
