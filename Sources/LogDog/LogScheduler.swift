import Foundation

public protocol LogScheduler {
    func schedule(_ action: @escaping () -> Void)
}

extension DispatchQueue: LogScheduler {
    public func schedule(_ action: @escaping () -> Void) {
        async(execute: action)
    }
}

extension DispatchQueue {
    private struct Sync: LogScheduler {
        private let queue: DispatchQueue

        init(_ queue: DispatchQueue) {
            self.queue = queue
        }

        func schedule(_ action: @escaping () -> Void) {
            queue.sync(execute: action)
        }
    }

    public var immediate: LogScheduler {
        Sync(self)
    }
}
