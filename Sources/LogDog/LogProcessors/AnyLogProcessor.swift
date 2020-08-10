public struct AnyLogProcessor<Input, Output>: LogProcessor {
    
    private var box: ProcessorBox<Input, Output>
    
    public init<Processor>(_ processor: Processor) where Processor: LogProcessor, Processor.Input == Input, Processor.Output == Output {
        box = OtherProcessorBox(processor)
    }
    
    public init(_ closure: @escaping (Input) throws -> Output) {
        box = ClosureProcessorBox(closure)
    }
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] {
        get {
            box.contextCaptures
        }
        set {
            box.contextCaptures = newValue
        }
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try box.process(logEntry)
    }
}

private class ProcessorBox<Input, Output>: LogProcessor {
    
    var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
    
    func process(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        fatalError()
    }
}

private class ClosureProcessorBox<Input, Output>: ProcessorBox<Input, Output> {
    
    private var _contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    private let closure: (Input) throws -> Output
    
    init(_ closure: @escaping (Input) throws -> Output) {
        self.closure = closure
    }
    
    override var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] {
        get { _contextCaptures }
        set { _contextCaptures = newValue }
    }
    
    override func process(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try logEntry.map(closure)
    }
}

private class OtherProcessorBox<Processor>: ProcessorBox<Processor.Input, Processor.Output> where Processor: LogProcessor {
    
    private var processor: Processor
    
    init(_ processor: Processor) {
        self.processor = processor
    }
    
    override var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] {
        get {
            processor.contextCaptures
        }
        set {
            processor.contextCaptures = newValue
        }
    }
    
    override func process(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try processor.process(logEntry)
    }
}
