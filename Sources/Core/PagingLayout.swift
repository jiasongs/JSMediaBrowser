//
//  PagingLayout.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

open class PagingLayout: UICollectionViewFlowLayout {
    
    public var pageSpacing: CGFloat = 10
    
    fileprivate var isUpdates: Bool = false
    fileprivate var isBoundsChange: Bool = false
    
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
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        /// 调用performBatchUpdates, insertSections等方法（reloadData除外）后完成前会调用此方法
        self.isUpdates = true
    }
    
    open override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        /// 调用performBatchUpdates, insertSections等方法（reloadData除外）完成后会调用此方法
        self.isUpdates = false
    }
    
    open override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        /// collectionView的frame将要变化时会调用此方法
        self.isBoundsChange = true
    }
    
    open override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        /// collectionView的frame变化完成后会调用此方法
        self.isBoundsChange = false
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

extension PagingLayout {
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        self.configureInitialLayoutAttributes(attributes)
        return attributes
    }
    
    open override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind,
                                                                                                                          at: elementIndexPath)
        self.configureInitialLayoutAttributes(attributes)
        return attributes
    }
    
    open override func initialLayoutAttributesForAppearingDecorationElement(ofKind elementKind: String, at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.initialLayoutAttributesForAppearingDecorationElement(ofKind: elementKind,
                                                                                                                       at: decorationIndexPath)
        self.configureInitialLayoutAttributes(attributes)
        return attributes
    }
    
    fileprivate func configureInitialLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes?) {
        if !self.isUpdates && self.isBoundsChange {
            return
        }
        attributes?.alpha = 1.0
    }
    
}
