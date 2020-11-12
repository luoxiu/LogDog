import Foundation

/// Appends records to an in-memory array.
public final class MemoryLogAppender<Output>: LogAppender {
    private let lock = NSLock()

    private var records: [LogRecord<Output>] = []

    public var snapshot: [LogRecord<Output>] {
        lock.lock(); defer { lock.unlock() }
        return records
    }

    public init() {}

    public func append(_ record: LogRecord<Output>) throws {
        lock.lock(); defer { lock.unlock() }
        records.append(record)
    }
}
