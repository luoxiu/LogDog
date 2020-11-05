public extension LogSink {
    func eraseToAnyLogSink() -> AnyLogSink<Input, Output> {
        .init(self)
    }
}

public struct AnyLogSink<Input, Output>: LogSink {
    private let sink: AbstractSink<Input, Output>

    public init<Sink>(_ sink: Sink) where Sink: LogSink, Input == Sink.Input, Output == Sink.Output {
        self.sink = SinkBox(sink)
    }

    public func beforeSink(_ entry: LogEntry) {
        sink.beforeSink(entry)
    }

    public func sink(_ record: LogRecord<Input>, next: (Result<LogRecord<Output>?, Error>) -> Void) {
        sink.sink(record, next: next)
    }
}

private class AbstractSink<Input, Output>: LogSink {
    func beforeSink(_: LogEntry) {
        fatalError()
    }

    func sink(_: LogRecord<Input>, next _: (Result<LogRecord<Output>?, Error>) -> Void) {
        fatalError()
    }
}

private final class SinkBox<Sink>: AbstractSink<Sink.Input, Sink.Output> where Sink: LogSink {
    private let sink: Sink

    init(_ sink: Sink) {
        self.sink = sink
    }

    override func beforeSink(_ entry: LogEntry) {
        sink.beforeSink(entry)
    }

    override func sink(_ record: LogRecord<Input>, next: (Result<LogRecord<Output>?, Error>) -> Void) {
        sink.sink(record, next: next)
    }
}
