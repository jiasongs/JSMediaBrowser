//
//  PagingLayout.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

open class PagingLayout: UICollectionViewFlowLayout {
    
    public var pageSpacing: CGFloat = 10
    
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
        if let flowContext: UICollectionViewFlowLayoutInvalidationContext = context as? UICollectionViewFlowLayoutInvalidationContext {
            flowContext.invalidateFlowLayoutDelegateMetrics = self.shouldInvalidateLayout(forBoundsChange: newBounds)
            flowContext.invalidateFlowLayoutAttributes = self.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        return context
    }
    
}

extension PagingLayout {
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.alpha = 1.0
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        return attributes
    }
    
}

extension PagingLayout {
    
    open override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind,
                                                                                                                          at: elementIndexPath)
        attributes?.alpha = 1.0
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind,
                                                                                                                           at: elementIndexPath)
        return attributes
    }
    
}

extension PagingLayout {
    
    open override func initialLayoutAttributesForAppearingDecorationElement(ofKind elementKind: String, at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.initialLayoutAttributesForAppearingDecorationElement(ofKind: elementKind,
                                                                                                                       at: decorationIndexPath)
        attributes?.alpha = 1.0
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingDecorationElement(ofKind elementKind: String, at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.finalLayoutAttributesForDisappearingDecorationElement(ofKind: elementKind,
                                                                                                                        at: decorationIndexPath)
        return attributes
    }
    
}
