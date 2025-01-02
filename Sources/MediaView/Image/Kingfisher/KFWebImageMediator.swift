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
    
    public var options: KingfisherOptionsInfo
    
    public init(options: KingfisherOptionsInfo? = nil) {
        let defaultOptions = KingfisherManager.shared.defaultOptions
        self.options = defaultOptions + (options ?? [])
    }
    
    public func requestImage(
        for view: UIView,
        url: URL?,
        progress: @escaping WebImageMediatorDownloadProgress,
        completed: @escaping WebImageMediatorCompleted
    ) {
        guard let url = url else {
            view.jsmbkf_taskIdentifier = nil
            completed(.failure(self.generateError(KingfisherError.imageSettingError(reason: .emptySource))))
            return
        }
        
        let issuedIdentifier = AtomicInt()
        view.jsmbkf_taskIdentifier = issuedIdentifier
        
        let source = url.isFileURL ? Source.provider(LocalFileImageDataProvider(fileURL: url)) : Source.network(url)
        let options = self.options
        let task = KingfisherManager.shared.retrieveImage(
            with: source,
            options: options,
            progressBlock: {
                progress($0, $1)
            },
            downloadTaskUpdated: { newTask in
                MainThreadTask.currentOrAsync {
                    view.jsmbkf_imageTask = newTask
                }
            },
            completionHandler: { result in
                MainThreadTask.currentOrAsync {
                    guard issuedIdentifier == view.jsmbkf_taskIdentifier else {
                        let reason: KingfisherError.ImageSettingErrorReason
                        do {
                            let value = try result.get()
                            reason = .notCurrentSourceTask(result: value, error: nil, source: source)
                        } catch {
                            reason = .notCurrentSourceTask(result: nil, error: error, source: source)
                        }
                        completed(.failure(self.generateError(KingfisherError.imageSettingError(reason: reason))))
                        return
                    }
                    
                    view.jsmbkf_imageTask = nil
                    view.jsmbkf_taskIdentifier = nil
                    
                    switch result {
                    case .success(let value):
                        completed(.success(self.generateResult(value)))
                    case .failure(let error):
                        completed(.failure(self.generateError(error)))
                    }
                }
            }
        )
        view.jsmbkf_imageTask = task
    }
    
    public func cancelRequest(for view: UIView) {
        view.jsmbkf_imageTask?.cancel()
    }
    
}

extension KFWebImageMediator {
    
    private func generateResult(_ result: RetrieveImageResult) -> WebImageMediationResult {
        return WebImageMediationResult(
            image: result.image,
            data: result.cacheType == .none ? result.data() : nil,
            url: result.source.url
        )
    }
    
    private func generateError(_ error: KingfisherError) -> WebImageMediationError {
        let nsError = error as NSError
        return WebImageMediationError(
            error: nsError,
            isCancelled: error.isTaskCancelled
        )
    }
    
}

private struct AssociatedKeys {
    static var taskIdentifier: UInt8 = 0
    static var imageTask: UInt8 = 0
}

private extension UIView {
    
    var jsmbkf_taskIdentifier: AtomicInt? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.taskIdentifier) as? AtomicInt
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.taskIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var jsmbkf_imageTask: DownloadTask? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.imageTask) as? DownloadTask
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.imageTask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

private struct AtomicInt: Equatable {
    
    private static let lock = UnfairLock()
    private static var current: Int = 1
    
    private let value: Int
    
    fileprivate init() {
        self.value = AtomicInt.lock.withLock {
            let value = AtomicInt.current
            AtomicInt.current = value + 1
            return value
        }
    }
}

private final class UnfairLock {
    
    private let lock: os_unfair_lock_t
    
    init() {
        self.lock = .allocate(capacity: 1)
        self.lock.initialize(to: os_unfair_lock())
    }
    
    deinit {
        self.lock.deinitialize(count: 1)
        self.lock.deallocate()
    }
    
    func withLock<T>(execute work: () throws -> T) rethrows -> T {
        os_unfair_lock_lock(self.lock)
        defer {
            os_unfair_lock_unlock(self.lock)
        }
        return try work()
    }
    
}

private struct MainThreadTask {
    
    static func currentOrAsync(execute work: @MainActor @Sendable @escaping () -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated(work)
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
}
