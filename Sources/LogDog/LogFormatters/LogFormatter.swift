public protocol LogFormatter {
    associatedtype Input
    associatedtype Output
    
    var context: [String: () -> Logger.MetadataValue?] { get set }
    
    func format(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>
}

extension LogFormatter where Input == Void {
    
    public func process(_ rawLogEntry: LogEntry) throws -> ProcessedLogEntry<Output> {
        let void = ProcessedLogEntry<Void>(rawLogEntry, ())
        return try format(void)
    }
}

// MARK: - Concat
extension LogFormatter {
    
    public func combine<P>(_ other: P) -> MultiplexLogFormatter<Self, P> where P: LogFormatter, P.Input == Output {
        .init(self, other)
    }
}

public func +<A, B>(_ a: A, _ b: B) -> MultiplexLogFormatter<A, B> where A: LogFormatter, B: LogFormatter, A.Output == B.Input {
    a.combine(b)
}
