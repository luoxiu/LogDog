extension LogFormatter {
    
    public func eraseToAnyPublisher() -> AnyLogFormatter<Input, Output> {
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
    
    public var hooks: [LogHook]? {
        formatter.hooks
    }
    
    public func format(_ record: LogRecord<Input>) throws -> Output? {
        try formatter.format(record)
    }
}

private class AbstractFormatter<Input, Output>: LogFormatter {
    
    var hooks: [LogHook]? {
        fatalError()
    }
    
    func format(_ record: LogRecord<Input>) throws -> Output? {
        fatalError()
    }
}

private final class ClosureBox<Input, Output>: AbstractFormatter<Input, Output> {
    
    private let closure: (LogRecord<Input>) throws -> Output?
    
    init(_ closure: @escaping (LogRecord<Input>) throws -> Output?) {
        self.closure = closure
    }
    
    override var hooks: [LogHook]? {
        nil
    }
    
    override func format(_ record: LogRecord<Input>) throws -> Output? {
        try closure(record)
    }
}

private final class FormatterBox<Formatter>: AbstractFormatter<Formatter.Input, Formatter.Output> where Formatter: LogFormatter {
    
    private let formatter: Formatter
    
    init(_ formatter: Formatter) {
        self.formatter = formatter
    }
    
    override var hooks: [LogHook]? {
        formatter.hooks
    }
    
    override func format(_ record: LogRecord<Input>) throws -> Output? {
        try formatter.format(record)
    }
}

