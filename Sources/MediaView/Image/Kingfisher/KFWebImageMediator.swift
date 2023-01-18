//
//  KFWebImageMediator.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2023/01/18.
//

import UIKit
import Kingfisher
import ObjectiveC.runtime

public struct KFWebImageMediator: WebImageMediator {
    
    fileprivate var options: KingfisherOptionsInfo
    
    public func setImage(for view: UIView, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?) {
        guard let url = url else {
            view.jsmb_taskIdentifier = nil
            let userInfo = [NSLocalizedDescriptionKey: "url不能为空"]
            let error = NSError(domain: KingfisherError.domain, code: KingfisherError.imageSettingError(reason: .emptySource).errorCode, userInfo: userInfo)
            let webImageError = WebImageError(error: error, cancelled: false)
            completed?(.failure(webImageError))
            return
        }
        
        let issuedIdentifier = Identifier.next()
        view.jsmb_taskIdentifier = issuedIdentifier
        
        if let thumbImage = thumbImage {
            setImageBlock?(thumbImage)
        }
        
        let source = url.isFileURL ? Source.provider(LocalFileImageDataProvider(fileURL: url)) : Source.network(url)
        let options = self.options
        view.jsmb_imageTask = KingfisherManager.shared.retrieveImage(
            with: source,
            options: options,
            progressBlock: { receivedSize, totalSize in
                progress?(receivedSize, totalSize)
            },
            downloadTaskUpdated: { newTask in
                view.jsmb_imageTask = newTask
            },
            completionHandler: { result in
                guard issuedIdentifier == view.jsmb_taskIdentifier else {
                    let reason: KingfisherError.ImageSettingErrorReason
                    do {
                        let value = try result.get()
                        reason = .notCurrentSourceTask(result: value, error: nil, source: source)
                    } catch {
                        reason = .notCurrentSourceTask(result: nil, error: error, source: source)
                    }
                    let userInfo = [NSLocalizedDescriptionKey: "未知错误"]
                    let error = NSError(domain: KingfisherError.domain, code: KingfisherError.imageSettingError(reason: reason).errorCode, userInfo: userInfo)
                    let webImageError = WebImageError(error: error, cancelled: false)
                    completed?(.failure(webImageError))
                    return
                }
                view.jsmb_imageTask = nil
                view.jsmb_taskIdentifier = nil
                
                switch result {
                case .success(let value):
                    let webImageResult = WebImageResult(image: value.image, data: value.cacheType == .none ? value.data() : nil)
                    completed?(.success(webImageResult))
                case .failure(let error):
                    let userInfo = [NSLocalizedDescriptionKey: error.errorDescription ?? ""]
                    let nsError = NSError(domain: KingfisherError.domain, code: error.errorCode, userInfo: userInfo)
                    let webImageError = WebImageError(error: nsError, cancelled: error.isTaskCancelled)
                    completed?(.failure(webImageError))
                }
            }
        )
    }
    
    public func cancelImageRequest(for view: UIView) {
        view.jsmb_imageTask?.cancel()
    }
    
    public init(options: KingfisherOptionsInfo? = nil) {
        let defaultOptions = KingfisherManager.shared.defaultOptions
        self.options = defaultOptions + (options ?? [])
    }
    
}

fileprivate var taskIdentifierKey: Void?
fileprivate var imageTaskKey: Void?

fileprivate enum Identifier {
    
    public typealias Value = UInt
    
    static var current: Value = 0
    
    static func next() -> Value {
        self.current += 1
        return self.current
    }
    
}

extension UIView {
    
    fileprivate var jsmb_taskIdentifier: Identifier.Value? {
        get {
            let value = objc_getAssociatedObject(self, &taskIdentifierKey) as? NSNumber
            return value?.uintValue as? Identifier.Value
        }
        set {
            let number = newValue != nil ? NSNumber(value: newValue!) : nil
            objc_setAssociatedObject(self, &taskIdentifierKey, number, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    fileprivate var jsmb_imageTask: DownloadTask? {
        get {
            return objc_getAssociatedObject(self, &imageTaskKey) as? DownloadTask
        }
        set {
            objc_setAssociatedObject(self, &imageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
