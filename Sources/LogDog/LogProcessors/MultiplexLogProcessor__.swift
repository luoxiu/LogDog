public struct MultiplexLogProcessor<A, B>: LogProcessor where A: LogProcessor, B: LogProcessor, A.Output == B.Input {
    
    public typealias Input = A.Input
    public typealias Output = B.Output
    
    public var a: A
    public var b: B
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] {
        get {
            a.contextCaptures.merging(b.contextCaptures) { _, b in b }
        }
        set {
            a.contextCaptures = newValue
            b.contextCaptures = newValue
        }
    }
    
    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
    
    public func process(_ logEntry: ProcessedLogEntry<A.Input>) throws -> ProcessedLogEntry<B.Output> {
        let m = try a.process(logEntry)
        return try b.process(m)
    }
}
