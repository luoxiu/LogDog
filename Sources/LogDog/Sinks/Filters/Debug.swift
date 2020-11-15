import Foundation

public extension LogSink {
    func debug() -> LogSinks.Concat<Self, LogFilters.Debug<Output>> {
        self + .init()
    }
}

public extension LogFilters {
    struct Debug<Output>: LogSink {
        public typealias Input = Output

        public init() {}

        public func sink(_ record: LogRecord<Input>, next: @escaping LogSinkNext<Output>) {
            record.sink(next: next) { (record) -> Output? in
                guard let label = ProcessInfo.processInfo.environment["DEBUG"], label.count > 0 else {
                    return record.output
                }
                return label == record.entry.label ? record.output : nil
            }
        }
    }
}
