public struct MultiplexLogFormatter<A, B>: LogFormatter where A: LogFormatter, B: LogFormatter, A.Output == B.Input {
    
    public typealias Input = A.Input
    public typealias Output = B.Output
    
    public var a: A
    public var b: B
    
    public var context: [String : () -> Logger.MetadataValue?] {
        get {
            a.context.merging(b.context, uniquingKeysWith: { _, b in b })
        }
        set {
            a.context = newValue
            b.context = newValue
        }
    }
    
    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
    
    public func format(_ logEntry: ProcessedLogEntry<A.Input>) throws -> ProcessedLogEntry<B.Output> {
        let m = try a.format(logEntry)
        return try b.format(m)
    }
}
