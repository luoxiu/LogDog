/// Abstract class
open class LogProcessor<Input, Output> {
    
    public var contextCaptures: [String: () -> LossLessMetadataValueConvertible?]
    
    public let transform: (ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>
    
    public init(_ transform: @escaping (ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>) {
        self.transform = transform
        self.contextCaptures = [:]
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

// MARK: - Context
extension LogProcessor {
    public func register<T: LossLessMetadataValueConvertible>(_ capture: ContextCapture<T>) {
        contextCaptures[capture.name] = { () -> T in
            capture.capture()!
        }
    }
    
    public var contextSnapshot: [String: Logger.MetadataValue] {
        contextCaptures.compactMapValues { $0()?.metadataValue }
    }
}

// MARK: - Concat
extension LogProcessor {
    
    public func combine<T>(_ processor: LogProcessor<Output, T>) -> LogProcessor<Input, T> {
        let newProcessor = LogProcessor<Input, T> {
            let logEntry = try self.process($0)
            return try processor.process(logEntry)
        }
        
        newProcessor.contextCaptures.merge(contextCaptures, uniquingKeysWith: { _, b in b })
        newProcessor.contextCaptures.merge(processor.contextCaptures, uniquingKeysWith: { _, b in b })
        
        return newProcessor
    }
}

public func +<Input, Medium, Output>(_ processorA: LogProcessor<Input, Medium>, _ processorB: LogProcessor<Medium, Output>) -> LogProcessor<Input, Output> {
    processorA.combine(processorB)
}
