//
//  UIView+Kingfisher.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/31.
//  Copyright © 2020 jiasong. All rights reserved.
//

import UIKit
import Kingfisher

class Box<T> {
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}

func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private var taskIdentifierKey: Void?
private var imageTaskKey: Void?

extension KingfisherWrapper where Base: UIView {
    
    public private(set) var taskIdentifier: Source.Identifier.Value? {
        get {
            let box: Box<Source.Identifier.Value>? = getAssociatedObject(base, &taskIdentifierKey)
            return box?.value
        }
        set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(base, &taskIdentifierKey, box)
        }
    }
    
    private var imageTask: DownloadTask? {
        get { return getAssociatedObject(base, &imageTaskKey) }
        set { setRetainedAssociatedObject(base, &imageTaskKey, newValue)}
    }

}

extension KingfisherWrapper where Base: UIView {
    
    @discardableResult
    public func setImage(
        with source: Source?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        var mutatingSelf = self
        guard let source = source else {
            mutatingSelf.taskIdentifier = nil
            completionHandler?(.failure(KingfisherError.imageSettingError(reason: .emptySource)))
            return nil
        }

        var options = KingfisherParsedOptionsInfo(KingfisherManager.shared.defaultOptions + (options ?? []))

        options.preloadAllAnimationData = true

        if let block = progressBlock {
//            options.onDataReceived = (options.onDataReceived ?? []) + [ImageLoadingProgressSideEffect(block)]
        }

//        if let provider = ImageProgressiveProvider(options, refresh: { image in
//            self.base.image = image
//        }) {
//            options.onDataReceived = (options.onDataReceived ?? []) + [provider]
//        }
//
//        options.onDataReceived?.forEach {
//            $0.onShouldApply = { issuedIdentifier == self.taskIdentifier }
//        }
//
//        let task = KingfisherManager.shared.retrieveImage(
//            with: source,
//            options: options,
//            downloadTaskUpdated: { mutatingSelf.imageTask = $0 },
//            completionHandler: { result in
//                CallbackQueue.mainCurrentOrAsync.execute {
//                    maybeIndicator?.stopAnimatingView()
//                    guard issuedIdentifier == self.taskIdentifier else {
//                        let reason: KingfisherError.ImageSettingErrorReason
//                        do {
//                            let value = try result.get()
//                            reason = .notCurrentSourceTask(result: value, error: nil, source: source)
//                        } catch {
//                            reason = .notCurrentSourceTask(result: nil, error: error, source: source)
//                        }
//                        let error = KingfisherError.imageSettingError(reason: reason)
//                        completionHandler?(.failure(error))
//                        return
//                    }
//
//                    mutatingSelf.imageTask = nil
//                    mutatingSelf.taskIdentifier = nil
//
//                    switch result {
//                    case .success(let value):
//                        guard self.needsTransition(options: options, cacheType: value.cacheType) else {
//                            mutatingSelf.placeholder = nil
//                            self.base.image = value.image
//                            completionHandler?(result)
//                            return
//                        }
//
//                        self.makeTransition(image: value.image, transition: options.transition) {
//                            completionHandler?(result)
//                        }
//
//                    case .failure:
//                        if let image = options.onFailureImage {
//                            self.base.image = image
//                        }
//                        completionHandler?(result)
//                    }
//                }
//            }
//        )
//        mutatingSelf.imageTask = task
        return nil
    }
    
    public func cancelDownloadTask() {
        imageTask?.cancel()
    }
    
}
