public struct StdoutLogOutputStream: LogOutputStream {
    
    public init() { }
    
    public func write(_ logEntry: @autoclosure () throws -> ProcessedLogEntry<String>) rethrows {
        let logEntry = try logEntry()
        print(logEntry.output)
    }
}
