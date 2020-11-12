public extension LogSink where Self.Output: RangeReplaceableCollection {
    func suffix(_ suffix: Output) -> LogSinks.Concat<Self, LogFormatters.Suffix<Output>> {
        self + LogFormatters.Suffix<Output>(suffix: suffix)
    }
}

public extension LogFormatters {
    struct Suffix<T>: LogSink where T: RangeReplaceableCollection {
        public typealias Input = T
        public typealias Output = T

        public let suffix: T

        public init(suffix: T) {
            self.suffix = suffix
        }

        public func sink(_ record: LogRecord<T>, next: @escaping LogSinkNext<T>) {
            record.sink(before: next) { record in
                record.output + suffix
            }
        }
    }
}
