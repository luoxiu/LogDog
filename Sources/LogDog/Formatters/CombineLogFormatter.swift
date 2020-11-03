extension LogFormatter {
    
    public func combine<Other>(_ other: Other) -> CombineLogFormatter<Self, Other> where Other: LogFormatter, Other.Input == Output {
        .init(self, other)
    }
}

public func +<A, B>(_ a: A, _ b: B) -> CombineLogFormatter<A, B> where A: LogFormatter, B: LogFormatter, A.Output == B.Input {
    a.combine(b)
}

public struct CombineLogFormatter<A, B>: LogFormatter where A: LogFormatter, B: LogFormatter, A.Output == B.Input {
    
    public typealias Input = A.Input
    public typealias Output = B.Output
    
    public var a: A
    public var b: B
    
    /// b will override a.
    public var hooks: [LogHook]? {
        switch (a.hooks, b.hooks) {
        case (.none, .none):
            return nil
        case (.some(let hooks), .none):
            return hooks
        case (.none, .some(let hooks)):
            return hooks
        case (.some(let hooksA), .some(let hooksB)):
            return hooksA + hooksB
        }
    }
    
    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
    
    public func format(_ record: LogRecord<A.Input>) throws -> B.Output? {
        guard let newRecord = try record.formatted(by: a) else {
            return nil
        }
        return try b.format(newRecord)
    }
}
