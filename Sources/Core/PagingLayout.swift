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
    
    open func didInitialize() -> Void {
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.scrollDirection = .horizontal
        self.sectionInset = .zero
    }
    
}

extension PagingLayout {
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView else {
            return []
        }
        guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
            return []
        }
        var attributes: [UICollectionViewLayoutAttributes] = []
        let superAttributes: Array<UICollectionViewLayoutAttributes> = super.layoutAttributesForElements(in: rect) ?? []
        for attributesItem in superAttributes {
            if let newAttributesItem = attributesItem.copy() as? UICollectionViewLayoutAttributes, newAttributesItem.frame.intersects(rect) {
                let itemSize: CGSize = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: newAttributesItem.indexPath) ?? CGSize.zero
                let halfWidth: CGFloat = itemSize.width / 2.0
                let centerX: CGFloat = collectionView.contentOffset.x + halfWidth
                newAttributesItem.center = CGPoint(x: newAttributesItem.center.x + (newAttributesItem.center.x - centerX) / halfWidth * self.pageSpacing / 2, y: newAttributesItem.center.y)
                newAttributesItem.size = itemSize
                attributes.append(newAttributesItem)
            }
        }
        return attributes
    }
    
}

extension PagingLayout {
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        /// 去掉进入时的动画效果
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
        /// 去掉进入时的动画效果
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
        /// 去掉进入时的动画效果
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

extension PagingLayout {
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context: UICollectionViewLayoutInvalidationContext = super.invalidationContext(forBoundsChange: newBounds)
        if let flowContext: UICollectionViewFlowLayoutInvalidationContext = context as? UICollectionViewFlowLayoutInvalidationContext {
            flowContext.invalidateFlowLayoutDelegateMetrics = self.collectionView?.bounds.size != newBounds.size
        }
        return context
    }
    
}
