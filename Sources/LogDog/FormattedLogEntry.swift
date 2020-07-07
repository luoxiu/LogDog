public struct FormattedLogEntry<Output> {
    
    public let rawLog: LogEntry
    public let output: Output
    
    public init(_ rawLog: LogEntry, _ output: Output) {
        self.rawLog = rawLog
        self.output = output
    }
}

extension FormattedLogEntry {
    
    public func map<T>(_ body: (Output) throws -> T) rethrows -> FormattedLogEntry<T> {
        try FormattedLogEntry<T>(rawLog, body(output))
    }
    
    public var asVoid: FormattedLogEntry<Void> {
        map { _ in }
    }
}
