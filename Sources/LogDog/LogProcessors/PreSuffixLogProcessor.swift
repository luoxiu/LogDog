import Foundation

public struct PreSuffixLogProcessor<C>: LogProcessor where C: RangeReplaceableCollection {
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public typealias Input = C
    public typealias Output = C
    
    public let prefix: C
    public let suffix: C
    
    public init(prefix: C = C(), suffix: C = C()) {
        self.prefix = prefix
        self.suffix = suffix
    }
    
    public func process(_ logEntry: ProcessedLogEntry<C>) throws -> ProcessedLogEntry<C> {
        logEntry.map { string in
            prefix + string + suffix
        }
    }
}

public extension LogProcessor where Self.Output: RangeReplaceableCollection {
    
    func prefix(_ prefix: Output) -> CombineLogProcessor<Self.Input, Self.Output> {
        self + PreSuffixLogProcessor<Output>(prefix: prefix)
    }
    
    func suffix(_ suffix: Output) -> CombineLogProcessor<Self.Input, Self.Output> {
        self + PreSuffixLogProcessor<Output>(suffix: suffix)
    }
}
