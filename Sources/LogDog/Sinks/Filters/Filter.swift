public extension LogSink {
    func filter(
        isIncluded: @escaping (LogRecord<Output>) throws -> Bool
    )
        -> LogSinks.Concat<Self, LogSinks.Filter<Output>>
    {
        self + .init(isIncluded: isIncluded)
    }
}

public extension LogSinks {
    struct Filter<Output>: LogSink {
        public typealias Input = Output

        public let isIncluded: (LogRecord<Output>) throws -> Bool

        public init(isIncluded: @escaping (LogRecord<Input>) throws -> Bool) {
            self.isIncluded = isIncluded
        }

        public func sink(_ record: LogRecord<Input>, next: @escaping LogSinkNext<Output>) {
            record.sink(next: next) { (record) -> Output? in
                try self.isIncluded(record) ? record.output : nil
            }
        }
    }
}
