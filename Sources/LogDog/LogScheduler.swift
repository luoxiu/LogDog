import Foundation

public protocol LogScheduler {
    func schedule(_ body: @escaping () -> Void)
}

extension DispatchQueue: LogScheduler {
    public func schedule(_ body: @escaping () -> Void) {
        async(execute: body)
    }
}

extension DispatchQueue {
    private struct Sync: LogScheduler {
        private let queue: DispatchQueue

        init(_ queue: DispatchQueue) {
            self.queue = queue
        }

        func schedule(_ body: @escaping () -> Void) {
            queue.sync(execute: body)
        }
    }

    public var immediate: LogScheduler {
        Sync(self)
    }
}

extension OperationQueue: LogScheduler {
    public func schedule(_ body: @escaping () -> Void) {
        addOperation(body)
    }
}

extension OperationQueue {
    private struct Sync: LogScheduler {
        private let queue: OperationQueue

        init(_ queue: OperationQueue) {
            self.queue = queue
        }

        func schedule(_ body: @escaping () -> Void) {
            let sema = DispatchSemaphore(value: 0)

            queue.addOperation {
                body()
                sema.signal()
            }

            sema.wait()
        }
    }

    public var immediate: LogScheduler {
        Sync(self)
    }
}
