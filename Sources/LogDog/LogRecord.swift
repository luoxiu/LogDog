public struct LogRecord<Output> {
    public let entry: LogEntry

    public let output: Output

    public init(_ entry: LogEntry,
                _ output: Output)
    {
        self.entry = entry
        self.output = output
    }
}
