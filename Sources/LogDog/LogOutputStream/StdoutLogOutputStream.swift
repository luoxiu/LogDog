public final class StdoutLogOutputStream: LogOutputStream {
    
    public init() { }
    
    public func write(_ logEntry: @autoclosure () throws -> ProcessedLogEntry<String>) throws {
        let output = try logEntry().lazyOutput()
        print(output)
    }
}
