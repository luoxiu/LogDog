public struct FormattedLogEntry<Output> {
    
    public let origin: LogEntry
    public let output: Output
    
    public init(_ rawLog: LogEntry, _ output: Output) {
        self.origin = rawLog
        self.output = output
    }
}

extension FormattedLogEntry {
    
    public func map<T>(_ body: (Output) throws -> T) rethrows -> FormattedLogEntry<T> {
        try FormattedLogEntry<T>(origin, body(output))
    }
}
