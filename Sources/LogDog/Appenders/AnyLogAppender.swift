public struct AnyLogAppender<Output>: LogAppender {
    
    private let appender: AbstractAppender<Output>
    
    public init(_ closure: @escaping (LogRecord<Output>) throws -> Void) {
        self.appender = ClosureBox(closure)
    }
    
    public init<Appender>(_ appender: Appender) where Appender: LogAppender, Appender.Output == Output {
        self.appender = AppenderBox(appender)
    }
    
    public func append(_ record: LogRecord<Output>) throws {
        try appender.append(record)
    }
}

private class AbstractAppender<Output>: LogAppender {
    func append(_ record: LogRecord<Output>) throws {
        fatalError()
    }
}

private final class ClosureBox<Output>: AbstractAppender<Output> {
    
    private let closure: (LogRecord<Output>) throws -> Void
    
    init(_ closure: @escaping (LogRecord<Output>) throws -> Void) {
        self.closure = closure
    }
    
    override func append(_ record: LogRecord<Output>) throws {
        try closure(record)
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
