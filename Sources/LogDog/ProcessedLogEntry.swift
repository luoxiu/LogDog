public struct ProcessedLogEntry<Output> {
    
    public let rawLogEntry: LogEntry
    public let output: Output
    
    public init(_ rawLogEntry: LogEntry, _ output: Output) {
        self.rawLogEntry = rawLogEntry
        self.output = output
    }
}

extension ProcessedLogEntry {
    
    public func map<T>(_ transform: (Output) throws -> T) rethrows -> ProcessedLogEntry<T> {
        try ProcessedLogEntry<T>(rawLogEntry, transform(output))
    }
}
