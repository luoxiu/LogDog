public protocol LogSink {
    associatedtype Input
    associatedtype Output

    func beforeSink(_ entry: LogEntry)

    func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void)
}

public extension LogSink {
    func beforeSink(_: LogEntry) {
        // noop
    }
}
