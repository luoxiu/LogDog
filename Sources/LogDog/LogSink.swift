/// Sinks sink LogRecords.
public protocol LogSink {
    associatedtype Input
    associatedtype Output

    /// Before sinking, the sink has a chance to do something with the entry.
    func beforeSink(_ entry: inout LogEntry)

    func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void)
}

public extension LogSink {
    func beforeSink(_: inout LogEntry) {
        // noop
    }
}
