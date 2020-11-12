/// A type-erased appender.
public struct AnyLogAppender<Output>: LogAppender {
    private let appender: AbstractAppender<Output>

    public init(_ append: @escaping (LogRecord<Output>) throws -> Void) {
        appender = AppenderBodyBox(append)
    }

    public init<Appender>(_ appender: Appender) where Appender: LogAppender, Appender.Output == Output {
        self.appender = AppenderBox(appender)
    }

    public func append(_ record: LogRecord<Output>) throws {
        try appender.append(record)
    }
}

private class AbstractAppender<Output>: LogAppender {
    func append(_: LogRecord<Output>) throws {
        fatalError()
    }
}

private final class AppenderBodyBox<Output>: AbstractAppender<Output> {
    private let appendBody: (LogRecord<Output>) throws -> Void

    init(_ append: @escaping (LogRecord<Output>) throws -> Void) {
        appendBody = append
    }

    override func append(_ record: LogRecord<Output>) throws {
        try appendBody(record)
    }
}

private final class AppenderBox<Appender>: AbstractAppender<Appender.Output> where Appender: LogAppender {
    private let appender: Appender

    init(_ appender: Appender) {
        self.appender = appender
    }

    override func append(_ record: LogRecord<Output>) throws {
        try appender.append(record)
    }
}
