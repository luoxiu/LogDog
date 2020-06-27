public struct Log<Output> {
    
    public let rawLog: RawLog
    public let output: Output
    
    public init(_ rawLog: RawLog, _ output: Output) {
        self.rawLog = rawLog
        self.output = output
    }
}

extension Log {
    
    public func map<T>(_ body: (Output) throws -> T) rethrows -> Log<T> {
        try Log<T>(rawLog, body(output))
    }
    
    public var asVoid: Log<Void> {
        map { _ in }
    }
}
