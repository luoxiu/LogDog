import Foundation

public struct SuffixLogFormatter<T>: LogFormatter where T: RangeReplaceableCollection {
    
    public typealias Input = T
    public typealias Output = T
    
    public let suffix: T
    
    public init(suffix: T) {
        self.suffix = suffix
    }
    
    public func format(_ record: LogRecord<T>) throws -> T? {
        record.output + suffix
    }
}

public extension LogFormatter where Self.Output: RangeReplaceableCollection {
    
    func suffix(_ suffix: Output) -> CombineLogFormatter<Self, SuffixLogFormatter<Output>> {
        self + SuffixLogFormatter<Output>(suffix: suffix)
    }
}
