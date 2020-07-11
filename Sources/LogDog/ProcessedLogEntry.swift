public struct ProcessedLogEntry<Output> {
    
    public let raw: LogEntry
    public let output: Output
    
    public init(_ raw: LogEntry, _ output: Output) {
        self.raw = raw
        self.output = output
    }
}

extension ProcessedLogEntry {
    
    public func map<T>(_ transform: (Output) throws -> T) rethrows -> ProcessedLogEntry<T> {
        try ProcessedLogEntry<T>(raw, transform(output))
    }
}
