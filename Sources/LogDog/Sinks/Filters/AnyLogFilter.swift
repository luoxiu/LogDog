public extension LogFilter {
    func eraseToAnyLogFilter() -> AnyLogFilter<Input> {
        .init(self)
    }
}

public struct AnyLogFilter<Input>: LogFilter {
    public typealias Output = Input

    private let filter: AbstractFilter<Input>

    public init<Filter>(_ filter: Filter) where Filter: LogFilter, Input == Filter.Input {
        self.filter = FilterBox(filter)
    }

    public init(_ filter: @escaping (LogRecord<Input>) -> Bool) {
        self.filter = ClosureBox(filter)
    }

    public func filter(_ record: LogRecord<Input>) -> Bool {
        filter.filter(record)
    }
}

private class AbstractFilter<Input>: LogFilter {
    typealias Output = Input

    func filter(_: LogRecord<Input>) -> Bool {
        fatalError()
    }
}

private final class ClosureBox<Input>: AbstractFilter<Input> {
    private let filter: (LogRecord<Input>) -> Bool

    init(_ filter: @escaping (LogRecord<Input>) -> Bool) {
        self.filter = filter
    }

    override func filter(_ record: LogRecord<Input>) -> Bool {
        filter(record)
    }
}

private final class FilterBox<Filter>: AbstractFilter<Filter.Input> where Filter: LogFilter {
    private let filter: Filter

    init(_ filter: Filter) {
        self.filter = filter
    }

    override func filter(_ record: LogRecord<Filter.Input>) -> Bool {
        filter.filter(record)
    }

    func beforeSink(_ entry: LogEntry) {
        filter.beforeSink(entry)
    }

    func sink(_ record: LogRecord<Filter.Input>, next: @escaping (Result<LogRecord<Filter.Output>?, Error>) -> Void) {
        filter.sink(record, next: next)
    }
}
