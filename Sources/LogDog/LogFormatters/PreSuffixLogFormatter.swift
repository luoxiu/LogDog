import Foundation

public struct PreSuffixLogFormatter<C>: LogFormatter where C: RangeReplaceableCollection {
    
    public var context: [String : () -> Logger.MetadataValue?] = [:]
    
    public typealias Input = C
    public typealias Output = C
    
    public let prefix: C
    public let suffix: C
    
    public init(prefix: C = C(), suffix: C = C()) {
        self.prefix = prefix
        self.suffix = suffix
    }
    
    public func format(_ logEntry: ProcessedLogEntry<C>) throws -> ProcessedLogEntry<C> {
        logEntry.map { string in
            prefix + string + suffix
        }
    }
}

public extension LogFormatter where Self.Output: RangeReplaceableCollection {
    
    func prefix(_ prefix: Output) -> MultiplexLogFormatter<Self, PreSuffixLogFormatter<Output>> {
        self + PreSuffixLogFormatter<Output>(prefix: prefix)
    }
    
    func suffix(_ suffix: Output) -> MultiplexLogFormatter<Self, PreSuffixLogFormatter<Output>> {
        self + PreSuffixLogFormatter<Output>(suffix: suffix)
    }
}
