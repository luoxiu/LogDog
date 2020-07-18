public protocol LogProcessor {
    associatedtype Input
    associatedtype Output
    
    var contextCaptures: [String: (LogEntry) -> LossLessMetadataValueConvertible?] { get set }
    
    func process(_ logEntry: ProcessedLogEntry<Input>) throws -> ProcessedLogEntry<Output>
}

extension LogProcessor where Input == Void {
    
    func process(_ rawLogEntry: LogEntry) throws -> ProcessedLogEntry<Output> {
        let void = ProcessedLogEntry<Void>(rawLogEntry, ())
        return try process(void)
    }
}

// MARK: - Context
extension LogProcessor {
    public mutating func register<T: LossLessMetadataValueConvertible>(_ capture: ContextCapture<T>) {
        contextCaptures[capture.name] = { logEntry -> T? in
            capture.capture(logEntry)
        }
    }
}

// MARK: - Concat
extension LogProcessor {
    
    public func combine<P>(_ other: P) -> MultiplexLogProcessor<Input, P.Output> where P: LogProcessor, P.Input == Output {
        .init(self, other)
    }
}

public func +<A, B>(_ a: A, _ b: B) -> MultiplexLogProcessor<A.Input, B.Output> where A: LogProcessor, B: LogProcessor, A.Output == B.Input {
    a.combine(b)
}
