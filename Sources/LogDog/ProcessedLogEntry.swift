public struct ProcessedLogEntry<Output> {
    
    public let rawLogEntry: LogEntry
    public let lazyOutput: () throws -> Output
    
    public init(_ rawLogEntry: LogEntry, _ output: @escaping () throws -> Output) {
        self.rawLogEntry = rawLogEntry
        self.lazyOutput = output
    }
}

extension ProcessedLogEntry {
    
    public func map<T>(_ transform: @escaping (Output) throws -> T) -> ProcessedLogEntry<T> {
        ProcessedLogEntry<T>(rawLogEntry) {
            let output = try self.lazyOutput()
            return try transform(output)
        }
    }
}
