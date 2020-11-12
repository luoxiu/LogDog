public extension LogSink {
    func eraseToAnyLogSink() -> AnyLogSink<Input, Output> {
        .init(self)
    }
}

public struct AnyLogSink<Input, Output>: LogSink {
    private let sink: AbstractSink<Input, Output>

    public init<Sink>(_ sink: Sink) where Sink: LogSink, Sink.Input == Input, Sink.Output == Output {
        self.sink = SinkBox(sink)
    }

    public init(beforeSink: @escaping (inout LogEntry) -> Void,
                sink: @escaping (LogRecord<Input>, (Result<LogRecord<Output>?, Error>) -> Void) -> Void)
    {
        self.sink = SinkBodyBox(beforeSink: beforeSink, sink: sink)
    }

    public func beforeSink(_ entry: inout LogEntry) {
        sink.beforeSink(&entry)
    }

    public func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void) {
        sink.sink(record, next: next)
    }
}

private class AbstractSink<Input, Output>: LogSink {
    func beforeSink(_: inout LogEntry) {
        fatalError()
    }

    func sink(_: LogRecord<Input>, next _: @escaping (Result<LogRecord<Output>?, Error>) -> Void) {
        fatalError()
    }
}

private final class SinkBodyBox<Input, Output>: AbstractSink<Input, Output> {
    private let beforeSinkBody: (inout LogEntry) -> Void
    private let sinkBody: (LogRecord<Input>, (Result<LogRecord<Output>?, Error>) -> Void) -> Void

    init(beforeSink: @escaping (inout LogEntry) -> Void,
         sink: @escaping (LogRecord<Input>, (Result<LogRecord<Output>?, Error>) -> Void) -> Void)
    {
        beforeSinkBody = beforeSink
        sinkBody = sink
    }

    override func beforeSink(_ entry: inout LogEntry) {
        beforeSinkBody(&entry)
    }

    override func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void) {
        sinkBody(record, next)
    }
}

private final class SinkBox<Sink>: AbstractSink<Sink.Input, Sink.Output> where Sink: LogSink {
    private let sink: Sink

    init(_ sink: Sink) {
        self.sink = sink
    }

    override func beforeSink(_ entry: inout LogEntry) {
        sink.beforeSink(&entry)
    }

    override func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void) {
        sink.sink(record, next: next)
    }
}
