public extension LogFormatter {
    func eraseToAnyLogFormatter() -> AnyLogFormatter<Input, Output> {
        .init(self)
    }
}

public struct AnyLogFormatter<Input, Output>: LogFormatter {
    private let formatter: AbstractFormatter<Input, Output>

    public init<Formatter>(_ formatter: Formatter) where Formatter: LogFormatter, Input == Formatter.Input, Output == Formatter.Output {
        self.formatter = FormatterBox(formatter)
    }

    public init(_ closure: @escaping (LogRecord<Input>) throws -> Output?) {
        formatter = ClosureBox(closure)
    }

    public func format(_ record: LogRecord<Input>) throws -> Output? {
        try formatter.format(record)
    }
}

private class AbstractFormatter<Input, Output>: LogFormatter {
    func format(_: LogRecord<Input>) throws -> Output? {
        fatalError()
    }
}

private final class ClosureBox<Input, Output>: AbstractFormatter<Input, Output> {
    private let format: (LogRecord<Input>) throws -> Output?

    init(_ format: @escaping (LogRecord<Input>) throws -> Output?) {
        self.format = format
    }

    override func format(_ record: LogRecord<Input>) throws -> Output? {
        try format(record)
    }
}

private final class FormatterBox<Formatter>: AbstractFormatter<Formatter.Input, Formatter.Output> where Formatter: LogFormatter {
    private let formatter: Formatter

    init(_ formatter: Formatter) {
        self.formatter = formatter
    }

    override func format(_ record: LogRecord<Input>) throws -> Output? {
        try formatter.format(record)
    }

    func beforeSink(_ entry: LogEntry) {
        formatter.beforeSink(entry)
    }

    func sink(_ record: LogRecord<Formatter.Input>, next: @escaping (Result<LogRecord<Formatter.Output>?, Error>) -> Void) {
        formatter.sink(record, next: next)
    }
}
