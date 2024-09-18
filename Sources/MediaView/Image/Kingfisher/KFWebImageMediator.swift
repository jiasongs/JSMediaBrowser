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
    
    private var options: KingfisherOptionsInfo
    
    public func setImage(
        for view: UIView,
        url: URL?,
        thumbImage: UIImage?,
        setImageBlock: WebImageMediatorSetImageBlock?,
        progress: WebImageMediatorDownloadProgress?,
        completed: WebImageMediatorCompleted?
    ) {
        guard let url = url else {
            view.jsmb_taskIdentifier = nil
            completed?(.failure(self.generateError(KingfisherError.imageSettingError(reason: .emptySource))))
            return
        }
        
        let issuedIdentifier = Identifier.next()
        view.jsmb_taskIdentifier = issuedIdentifier
        
        if let thumbImage = thumbImage {
            setImageBlock?(thumbImage)
        }
        
        let source = url.isFileURL ? Source.provider(LocalFileImageDataProvider(fileURL: url)) : Source.network(url)
        let options = self.options
        let parsedOptions = KingfisherParsedOptionsInfo(options)
        let task = KingfisherManager.shared.retrieveImage(
            with: source,
            options: options,
            progressBlock: { receivedSize, totalSize in
                progress?(receivedSize, totalSize)
            },
            downloadTaskUpdated: { newTask in
                view.jsmb_imageTask = newTask
            },
            completionHandler: { result in
                CallbackQueue.mainCurrentOrAsync.execute {
                    guard issuedIdentifier == view.jsmb_taskIdentifier else {
                        let reason: KingfisherError.ImageSettingErrorReason
                        do {
                            let value = try result.get()
                            reason = .notCurrentSourceTask(result: value, error: nil, source: source)
                        } catch {
                            reason = .notCurrentSourceTask(result: nil, error: error, source: source)
                        }
                        completed?(.failure(self.generateError(KingfisherError.imageSettingError(reason: reason))))
                        return
                    }
                    
                    view.jsmb_imageTask = nil
                    view.jsmb_taskIdentifier = nil
                    
                    switch result {
                    case .success(let value):
                        completed?(.success(self.generateResult(value)))
                    case .failure(let error):
                        if let image = parsedOptions.onFailureImage {
                            setImageBlock?(image)
                        }
                        completed?(.failure(self.generateError(error)))
                    }
                }
            }
        )
        view.jsmb_imageTask = task
    }
    
    public func cancelImageRequest(for view: UIView) {
        view.jsmb_imageTask?.cancel()
    }
    
    public init(options: KingfisherOptionsInfo? = nil) {
        let defaultOptions = KingfisherManager.shared.defaultOptions
        self.options = defaultOptions + (options ?? [])
    }
    
}

extension KFWebImageMediator {
    
    private func generateResult(_ result: RetrieveImageResult) -> WebImageResult {
        let webImageResult = WebImageResult(image: result.image, data: result.cacheType == .none ? result.data() : nil, url: result.source.url)
        return webImageResult
    }
    
    private func generateError(_ error: KingfisherError) -> WebImageError {
        let userInfo = [NSLocalizedDescriptionKey: error.errorDescription ?? ""]
        let nsError = NSError(domain: KingfisherError.domain, code: error.errorCode, userInfo: userInfo)
        let webImageError = WebImageError(error: nsError, cancelled: error.isTaskCancelled)
        return webImageError
    }
    
}

private var taskIdentifierKey: UInt8 = 0
private var imageTaskKey: UInt8 = 0

private enum Identifier {
    
    public typealias Value = UInt
    
    static var current: Value = 0
    
    static func next() -> Value {
        self.current += 1
        return self.current
    }
    
}

private extension UIView {
    
    var jsmb_taskIdentifier: Identifier.Value? {
        get {
            let value = objc_getAssociatedObject(self, &taskIdentifierKey) as? NSNumber
            return value?.uintValue as? Identifier.Value
        }
        set {
            let number = newValue != nil ? NSNumber(value: newValue!) : nil
            objc_setAssociatedObject(self, &taskIdentifierKey, number, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var jsmb_imageTask: DownloadTask? {
        get {
            return objc_getAssociatedObject(self, &imageTaskKey) as? DownloadTask
        }
        set {
            objc_setAssociatedObject(self, &imageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
