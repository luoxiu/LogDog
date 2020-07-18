// MARK: - MultiplexLogProcessor
public struct MultiplexLogProcessor<Input, Output>: LogProcessor {
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?]
    
    private let transform: (ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>
    
    public init<A, B>(_ a: A, _ b: B) where A: LogProcessor, B: LogProcessor, A.Input == Input, B.Output == Output, A.Output == B.Input {
        contextCaptures = a.contextCaptures.merging(b.contextCaptures) { _, b in b }
        
        transform = { logEntry in
            let m = try a.process(logEntry)
            return try b.process(m)
        }
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output> {
        try transform(logEntry)
    }
}
