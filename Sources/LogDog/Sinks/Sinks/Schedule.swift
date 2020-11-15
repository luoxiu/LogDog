import Foundation

public extension LogSink {
    func sink(on scheduler: LogScheduler) -> LogSinks.Concat<Self, LogSinks.SinkOn<Output>> {
        self + .init(scheduler)
    }
}

public extension LogSinks {
    struct SinkOn<Input>: LogSink {
        public typealias Output = Input

        public let scheduler: LogScheduler

        public init(_ scheduler: LogScheduler) {
            self.scheduler = scheduler
        }

        public func sink(_ record: LogRecord<Input>, next: @escaping LogSinkNext<Output>) {
            scheduler.schedule {
                next(.success(record))
            }
        }
    }
}
