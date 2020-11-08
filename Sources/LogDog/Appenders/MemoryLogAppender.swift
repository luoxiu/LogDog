import Foundation

public final class MemoryLogAppender<Output>: LogAppender {
    
    private let lock = NSLock()
    
    private var storage: [LogRecord<Output>] = []
    
    public var records: [LogRecord<Output>] {
        lock.lock()
        defer {
            lock.unlock()
        }
        return storage
    }
    
    public init() {
    }
    
    public func append(_ record: LogRecord<Output>) throws {
        lock.lock()
        defer {
            lock.unlock()
        }
        storage.append(record)
    }
}
