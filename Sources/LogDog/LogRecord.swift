public struct LogRecord<Output> {
    
    public let entry: LogEntry
    
    public let output: Output
    
    public init(_ entry: LogEntry,
                _ output: Output) {
        self.entry = entry
        self.output = output
    }
}

extension LogRecord {
    
    public func formatted<Formatter>(by formatter: Formatter) throws -> LogRecord<Formatter.Output>?
        where Formatter: LogFormatter, Formatter.Input == Output
    {
        guard let newOutput = try formatter.format(self) else {
            return nil
        }
        return LogRecord<Formatter.Output>(entry, newOutput)
    }
}
