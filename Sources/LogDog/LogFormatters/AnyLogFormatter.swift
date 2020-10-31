public struct AnyLogFormatter<Input, Output>: LogFormatter {
    
    private var box: AbstractBox<Input, Output>
    
    public init<Formatter>(_ formatter: Formatter) where Formatter: LogFormatter, Formatter.Input == Input, Formatter.Output == Output {
        box = FormatterBox(formatter)
    }
    
    public init(_ closure: @escaping (Input) throws -> Output) {
        box = ClosureBox(closure)
    }
    
    public var context: [String: () -> Logger.MetadataValue?] {
        get {
            box.context
        }
        set {
            box.context = newValue
        }
    }
    
    public func format(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try box.format(logEntry)
    }
}

private class AbstractBox<Input, Output>: LogFormatter {
    
    var context: [String : () -> Logger.MetadataValue?] {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
    
    func format(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        fatalError()
    }
}

private class ClosureBox<Input, Output>: AbstractBox<Input, Output> {
    
    private var ctx: [String : () -> Logger.MetadataValue?] = [:]
    
    private let closure: (Input) throws -> Output
    
    init(_ closure: @escaping (Input) throws -> Output) {
        self.closure = closure
    }
    
    override var context: [String : () -> Logger.MetadataValue?] {
        get { ctx }
        set { ctx = newValue }
    }
    
    override func format(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try logEntry.map(closure)
    }
}

private class FormatterBox<Processor>: AbstractBox<Processor.Input, Processor.Output> where Processor: LogFormatter {
    
    private var processor: Processor
    
    init(_ processor: Processor) {
        self.processor = processor
    }
    
    override var context: [String : () -> Logger.MetadataValue?] {
        get {
            processor.context
        }
        set {
            processor.context = newValue
        }
    }
    
    override func format(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try processor.format(logEntry)
    }
}
