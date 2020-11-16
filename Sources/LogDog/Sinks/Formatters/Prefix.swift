public extension LogSink where Output: RangeReplaceableCollection {
    func prefix(_ prefix: Output) -> LogSinks.Concat<Self, LogSinks.Prefix<Output>> {
        self + LogSinks.Prefix<Output>(prefix: prefix)
    }
}

public extension LogSinks {
    struct Prefix<T>: LogSink where T: RangeReplaceableCollection {
        public typealias Input = T
        public typealias Output = T

        public let prefix: T

        public init(prefix: T) {
            self.prefix = prefix
        }

        public func sink(_ record: LogRecord<T>, next: @escaping LogSinkNext<T>) {
            record.sink(next: next) { record in
                prefix + record.output
            }
        }
    }
}
