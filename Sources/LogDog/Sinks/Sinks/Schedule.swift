import Foundation

public extension LogScheduler {
    func schedule<Sink: LogSink>(_ sink: Sink) -> LogSinks.Schedule<Sink, Self> {
        .init(sink, self)
    }
}

public extension LogSink {
    func sink<Scheduler: LogScheduler>(on scheduler: Scheduler) -> LogSinks.SinkOn<Self, Scheduler> {
        .init(self, scheduler)
    }
}

public extension LogSinks {
    struct Schedule<Sink, Scheduler>: LogSink where Sink: LogSink, Scheduler: LogScheduler {
        public typealias Input = Sink.Input
        public typealias Output = Sink.Output

        public let sink: Sink
        public let scheduler: Scheduler

        public init(_ sink: Sink, _ scheduler: Scheduler) {
            self.sink = sink
            self.scheduler = scheduler
        }

        public func beforeSink(_ entry: LogEntry) {
            sink.beforeSink(entry)
        }

        public func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void) {
            scheduler.schedule {
                sink.sink(record, next: next)
            }
        }
    }

    struct SinkOn<Sink, Scheduler>: LogSink where Sink: LogSink, Scheduler: LogScheduler {
        public typealias Input = Sink.Input
        public typealias Output = Sink.Output

        public let sink: Sink
        public let scheduler: Scheduler

        public init(_ sink: Sink, _ scheduler: Scheduler) {
            self.sink = sink
            self.scheduler = scheduler
        }

        public func beforeSink(_ entry: LogEntry) {
            sink.beforeSink(entry)
        }

        public func sink(_ record: LogRecord<Input>, next: @escaping (Result<LogRecord<Output>?, Error>) -> Void) {
            sink.sink(record) { record in
                scheduler.schedule {
                    next(record)
                }
            }
        }
    }
}
