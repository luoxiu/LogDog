/// The sink is responsible for maintaining fifo.
public protocol LogSink {
    associatedtype Input
    associatedtype Output

    /// hooks
    func beforeSink(_ entry: LogEntry)

    func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void)
}

public extension LogSink {
    func beforeSink(_: LogEntry) {
        // noop
    }
}
