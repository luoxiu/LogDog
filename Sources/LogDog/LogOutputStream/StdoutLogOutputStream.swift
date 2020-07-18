public final class StdoutLogOutputStream: LogOutputStream {
    
    public init() { }
    
    public func write(_ logEntry: ProcessedLogEntry<String>) throws {
        let output = logEntry.output
        print(output)
    }
}
