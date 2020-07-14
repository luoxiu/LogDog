public struct ProcessedLogEntry<Output> {
    
    public let rawLogEntry: LogEntry
    public let output: () throws -> Output
    
    public init(_ rawLogEntry: LogEntry, _ output: @escaping () throws -> Output) {
        self.rawLogEntry = rawLogEntry
        self.output = output
    }
}

extension ProcessedLogEntry {
    
    public func map<T>(_ transform: @escaping (Output) throws -> T) -> ProcessedLogEntry<T> {
        ProcessedLogEntry<T>(rawLogEntry) {
            let output = try self.output()
            return try transform(output)
        }
    }
}
