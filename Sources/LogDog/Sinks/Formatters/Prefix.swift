public extension LogSink where Self.Output: RangeReplaceableCollection {
    func prefix(_ prefix: Output) -> LogSinks.Concat<Self, LogFormatters.Prefix<Output>> {
        self + LogFormatters.Prefix<Output>(prefix: prefix)
    }
}

public extension LogFormatters {
    struct Prefix<T>: LogFormatter where T: RangeReplaceableCollection {
        public typealias Input = T
        public typealias Output = T

        public let prefix: T

        public init(prefix: T) {
            self.prefix = prefix
        }

        public func format(_ record: LogRecord<T>) throws -> T? {
            prefix + record.output
        }
    }
}
