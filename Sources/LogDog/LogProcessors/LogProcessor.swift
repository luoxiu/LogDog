open class LogProcessor<Input, Output> {
    
    public var dynamicContext: [String: () -> LossLessMetadataValueConvertible?]
    
    private let transform: (ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>
    
    public init(_ transform: @escaping (ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>) {
        self.transform = transform
        self.dynamicContext = [:]
    }
    
    open func process(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try transform(logEntry)
    }
}

extension LogProcessor {
    
    public var contextSnapshot: [String: Logger.MetadataValue] {
        dynamicContext.compactMapValues { $0()?.metadataValue }
    }
}

extension LogProcessor where Input == Void {
    
    open func process(_ logEntry: LogEntry) throws -> ProcessedLogEntry<Output> {
        try transform(ProcessedLogEntry(logEntry, ()))
    }
}

extension LogProcessor {
    
    public func concat<T>(_ processor: LogProcessor<Output, T>) -> LogProcessor<Input, T> {
        let formatter = LogProcessor<Input, T> {
            let logEntry = try self.process($0)
            return try processor.process(logEntry)
        }
        
        formatter.dynamicContext.merge(dynamicContext, uniquingKeysWith: { _, b in b })
        formatter.dynamicContext.merge(processor.dynamicContext, uniquingKeysWith: { _, b in b })
        
        return formatter
    }
}

public func +<Input, Medium, Output>(_ processorA: LogProcessor<Input, Medium>, _ processorB: LogProcessor<Medium, Output>) -> LogProcessor<Input, Output> {
    processorA.concat(processorB)
}

