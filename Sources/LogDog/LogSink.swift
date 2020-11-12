
public typealias LogSinkNext<Output> = (Result<LogRecord<Output>?, Error>) -> Void

public typealias LogRecordTransform<Output, NewOutput> = (LogRecord<Output>) throws -> NewOutput?

/// Sinks sink LogRecords.
public protocol LogSink {
    associatedtype Input
    associatedtype Output

    /// Before sinking, the sink has a chance to do something on entry.
    func beforeSink(_ entry: inout LogEntry)

    func sink(_ record: LogRecord<Input>, next: @escaping LogSinkNext<Output>)
}

public extension LogSink {
    func beforeSink(_: inout LogEntry) {
        // noop
    }
}

public extension LogRecord {
    func sink<NewOutput>(before next: @escaping LogSinkNext<NewOutput>, _ transform: @escaping LogRecordTransform<Output, NewOutput>) {
        let result = Result<LogRecord<NewOutput>?, Error> { () -> LogRecord<NewOutput>? in
            try transform(self)
                .map {
                    .init(entry, $0)
                }
        }
        next(result)
    }
}
