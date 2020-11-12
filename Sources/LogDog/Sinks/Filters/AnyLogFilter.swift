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

    public init(filter: @escaping (LogRecord<Input>) throws -> Bool) {
        self.filter = FilterBodyBox(filter: filter)
    }

    public func filter(_ record: LogRecord<Input>) throws -> Bool {
        try filter.filter(record)
    }
}

private class AbstractFilter<Input>: LogFilter {
    typealias Output = Input

    func filter(_: LogRecord<Input>) throws -> Bool {
        fatalError()
    }
}

private final class FilterBodyBox<Input>: AbstractFilter<Input> {
    private let filterBody: (LogRecord<Input>) throws -> Bool

    init(filter: @escaping (LogRecord<Input>) throws -> Bool) {
        filterBody = filter
    }

    override func filter(_ record: LogRecord<Input>) throws -> Bool {
        try filterBody(record)
    }
}

private final class FilterBox<Filter>: AbstractFilter<Filter.Input> where Filter: LogFilter {
    private let filter: Filter

    init(_ filter: Filter) {
        self.filter = filter
    }

    override func filter(_ record: LogRecord<Filter.Input>) throws -> Bool {
        try filter.filter(record)
    }

    func beforeSink(_ entry: inout LogEntry) {
        filter.beforeSink(&entry)
    }

    func sink(_ record: LogRecord<Filter.Input>, next: @escaping (Result<LogRecord<Filter.Output>?, Error>) -> Void) {
        filter.sink(record, next: next)
    }
}
