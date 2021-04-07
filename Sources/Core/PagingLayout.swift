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
    @objc public var velocityForEnsurePageDown: CGFloat = 0.4
    @objc public var allowsMultipleItemScroll: Bool = false
    @objc public var multipleItemScrollVelocityLimit: CGFloat = 2.5
    @objc public var pagingThreshold: CGFloat = 2.0 / 3.0
    
    fileprivate var finalItemSize: CGSize = CGSize.zero
    
    override init() {
        super.init()
        self.didInitialize()
    }
    
    required public init?(coder: NSCoder) {
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
    
    /// TODO：超大图浏览时, 导致有抖动的情况发生, 需要解决
    open override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else {
            return
        }
        var itemSize: CGSize = self.itemSize
        if let layoutDelegate = collectionView.delegate,
           layoutDelegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
            let delegate = layoutDelegate as! UICollectionViewDelegateFlowLayout
            itemSize = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: IndexPath(item: 0, section: 0)) ?? CGSize.zero
        }
        self.finalItemSize = itemSize
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return self.collectionView?.bounds.size != newBounds.size
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)
    }
    
//    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        guard let collectionView = self.collectionView else {
//            return CGPoint.zero
//        }
//        var finalProposedContentOffset: CGPoint = proposedContentOffset
//        let itemSpacing: CGFloat = self.pageSpacing
//        let contentSize: CGSize = self.collectionViewContentSize;
//        let frameSize: CGSize = collectionView.bounds.size;
//        var contentInset: UIEdgeInsets
//        if #available(iOS 11.0, *) {
//            contentInset = collectionView.adjustedContentInset
//        } else {
//            contentInset = collectionView.contentInset
//        };
//
//        let scrollingToRight: Bool = finalProposedContentOffset.x < collectionView.contentOffset.x;// 代表 collectionView 期望的实际滚动方向是向右，但不代表手指拖拽的方向是向右，因为有可能此时已经在左边的尽头，继续往右拖拽，松手的瞬间由于回弹，这里会判断为是想向左滚动，但其实你的手指是向右拖拽
//        var forcePaging: Bool = false;
//
//        let translation: CGPoint = collectionView.panGestureRecognizer.translation(in: collectionView)
//
//        if (!self.allowsMultipleItemScroll || abs(velocity.x) <= abs(self.multipleItemScrollVelocityLimit)) {
//            finalProposedContentOffset = collectionView.contentOffset;// 一次性滚多次的本质是系统根据速度算出来的 proposedContentOffset 可能比当前 contentOffset 大很多，所以这里既然限制了一次只能滚一页，那就直接取瞬时 contentOffset 即可。
//
//            // 只支持滚动一页 或者 支持滚动多页但是速度不够滚动多页，时，允许强制滚动
//            if (abs(velocity.x) > self.velocityForEnsurePageDown) {
//                forcePaging = true;
//            }
//        }
//
//        // 最左/最右
//        if (finalProposedContentOffset.x < -contentInset.left || finalProposedContentOffset.x >= contentSize.width + contentInset.right - frameSize.width) {
//            // iOS 10 及以上的版本，直接返回当前的 contentOffset，系统会自动帮你调整到边界状态，而 iOS 9 及以下的版本需要自己计算
//            return finalProposedContentOffset;
//        }
//
//        let progress: CGFloat = ((contentInset.left + finalProposedContentOffset.x) + self.finalItemSize.width / 2/*因为第一个 item 初始状态中心点离 contentOffset.x 有半个 item 的距离*/) / itemSpacing;
//        let currentIndex: Int = Int(progress);
//        var targetIndex: Int = currentIndex;
//        // 加上下面这两个额外的 if 判断是为了避免那种“从0滚到1的左边 1/3，松手后反而会滚回0”的 bug
//        if translation.x < 0 && (abs(translation.x) > self.finalItemSize.width / 2 + self.minimumLineSpacing) {
//        } else if translation.x > 0 && translation.x > self.finalItemSize.width / 2 {
//        } else {
//            let remainder: CGFloat = progress - CGFloat(currentIndex);
//            let offset: CGFloat = remainder * itemSpacing;
//            // collectionView 关闭了 bounces 后，如果在第一页向左边快速滑动一段距离，并不会触发上一个「最左/最右」的判断（因为 proposedContentOffset 不够），此时的 velocity 为负数，所以要加上 velocity.x > 0 的判断，否则这种情况会命中 forcePaging && !scrollingToRight 这两个条件，当做下一页处理。
//            let shouldNext: Bool = (forcePaging || (offset / self.finalItemSize.width >= self.pagingThreshold)) && !scrollingToRight && velocity.x > 0;
//            let shouldPrev: Bool = (forcePaging || (offset / self.finalItemSize.width <= 1 - self.pagingThreshold)) && scrollingToRight && velocity.x < 0;
//            targetIndex = currentIndex + (shouldNext ? 1 : (shouldPrev ? -1 : 0));
//        }
//        finalProposedContentOffset.x = -contentInset.left + CGFloat(targetIndex) * itemSpacing;
//        return finalProposedContentOffset;
//    }
   
}
