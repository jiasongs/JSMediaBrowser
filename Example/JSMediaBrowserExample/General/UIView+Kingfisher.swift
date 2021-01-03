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
        let task = KingfisherManager.shared.retrieveImage(with: source, options: nil) { (receivedSize, expectedSize) in
            
        } downloadTaskUpdated: { (task: DownloadTask?) in
            
        } completionHandler: { (result: Result<RetrieveImageResult, KingfisherError>) in
            CallbackQueue.mainCurrentOrAsync.execute {
                
                mutatingSelf.imageTask = nil
                mutatingSelf.taskIdentifier = nil

                switch result {
                case .success:
                    completionHandler?(result)
                case .failure:
                    completionHandler?(result)
                }
            }
        }
        mutatingSelf.imageTask = task
        return nil
    }
    
    public func cancelDownloadTask() {
        imageTask?.cancel()
    }
    
}
