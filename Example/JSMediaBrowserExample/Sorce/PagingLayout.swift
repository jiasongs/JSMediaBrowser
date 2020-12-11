//
//  PagingLayout.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/10.
//

import UIKit

class PagingLayout: UICollectionViewFlowLayout {
    
    public var pageSpacing: CGFloat = 10
    private var finalItemSize: CGSize = CGSize.zero
    
    override init() {
        super.init()
        self.didInitialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.didInitialize()
    }
    
    func didInitialize() -> Void {
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.scrollDirection = .horizontal
        self.sectionInset = .zero
    }
    
}

extension PagingLayout {
    
    override func prepare() {
        super.prepare()
        var itemSize: CGSize = self.itemSize
        guard let collectionView = self.collectionView else { return }
        if let layoutDelegate = collectionView.delegate {
            if layoutDelegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
                let delegate = layoutDelegate as! UICollectionViewDelegateFlowLayout
                itemSize = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: IndexPath.init(item: 0, section: 0)) ?? CGSize.zero
            }
        }
        self.finalItemSize = itemSize;
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttsArray = Array<UICollectionViewLayoutAttributes>.init()
        layoutAttsArray.append(contentsOf: super.layoutAttributesForElements(in: rect) ?? [])
        let halfWidth: CGFloat = self.finalItemSize.width / 2.0
        let centerX: CGFloat = (self.collectionView?.contentOffset.x ?? 0.0) + halfWidth
        for attributes in layoutAttsArray {
            attributes.center = CGPoint.init(x: attributes.center.x + (attributes.center.x - centerX) / halfWidth * self.pageSpacing / 2, y: attributes.center.y)
            attributes.size = self.finalItemSize;
        }
        return layoutAttsArray;
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
