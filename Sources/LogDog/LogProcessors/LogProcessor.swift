open class LogProcessor<Input, Output> {
    
    open var dynamicContext: [String: () -> MetadataValueConvertible]
    
    private let transform: (ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>
    
    public init(_ transform: @escaping (ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>) {
        self.dynamicContext = [:]
        self.transform = transform
    }
    
    open func process(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try transform(logEntry)
    }
}

extension LogProcessor where Input == Void {
    
    open func process(_ logEntry: LogEntry) throws -> ProcessedLogEntry<Output> {
        try transform(ProcessedLogEntry(logEntry, ()))
    }
}

extension LogProcessor {
    
    public func concat<T>(_ processor: LogProcessor<Output, T>) -> LogProcessor<Input, T> {
        return .init {
            let logEntry = try self.process($0)
            return try processor.process(logEntry)
        }
    }
}

public func +<Input, Medium, Output>(_ processorA: LogProcessor<Input, Medium>, _ processorB: LogProcessor<Medium, Output>) -> LogProcessor<Input, Output> {
    processorA.concat(processorB)
}

