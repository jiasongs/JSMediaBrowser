//
//  PagingLayout.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

@objc(JSMediaBrowserPagingLayout)
open class PagingLayout: UICollectionViewFlowLayout {
    
    @objc public var pageSpacing: CGFloat = 10
    
    fileprivate var attributes: [UICollectionViewLayoutAttributes] = []
    fileprivate var finalItemSize: CGSize = CGSize.zero
    
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
    
    open override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else {
            return
        }
        guard let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
            return
        }
        self.attributes.removeAll()
        let sectionCount: Int = collectionView.numberOfSections
        for section: Int in 0..<sectionCount {
            let itemCount = collectionView.numberOfItems(inSection: section)
            for item in 0..<itemCount {
                let indexPath: IndexPath = IndexPath(item: item, section: section)
                if let attributes: UICollectionViewLayoutAttributes = self.layoutAttributesForItem(at: indexPath) {
                    var itemSize: CGSize = self.itemSize
                    if delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
                        itemSize = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? CGSize.zero
                    }
                    let halfWidth: CGFloat = itemSize.width / 2.0
                    let centerX: CGFloat = collectionView.contentOffset.x + halfWidth
                    attributes.center = CGPoint(x: attributes.center.x + (attributes.center.x - centerX) / halfWidth * self.pageSpacing / 2, y: attributes.center.y)
                    attributes.size = itemSize
                    self.attributes.append(attributes)
                }
            }
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributes
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
