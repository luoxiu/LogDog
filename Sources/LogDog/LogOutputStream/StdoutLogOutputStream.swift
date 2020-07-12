public struct StdoutLogOutputStream: LogOutputStream {
    
    public init() { }
    
    public func write(_ logEntry: @autoclosure () throws -> ProcessedLogEntry<String>) rethrows {
        let output = try logEntry().output
        print(output)
    }
}
