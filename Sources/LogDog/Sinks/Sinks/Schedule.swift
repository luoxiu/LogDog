import Foundation

public extension LogScheduler {
    func schedule<Sink: LogSink>(_ sink: Sink) -> LogSinks.Schedule<Sink.Input, Sink.Output> {
        .init(sink, self)
    }
}

public extension LogSink {
    func sink(on scheduler: LogScheduler) -> LogSinks.SinkOn<Input, Output> {
        .init(self, scheduler)
    }
}

public extension LogSinks {
    struct Schedule<Input, Output>: LogSink {
        private let sink: AnyLogSink<Input, Output>
        private let scheduler: LogScheduler

        public init<Sink>(_ sink: Sink, _ scheduler: LogScheduler) where Sink: LogSink, Sink.Input == Input, Sink.Output == Output {
            self.sink = AnyLogSink(sink)
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

    struct SinkOn<Input, Output>: LogSink {
        private let sink: AnyLogSink<Input, Output>
        private let scheduler: LogScheduler

        public init<Sink>(_ sink: Sink, _ scheduler: LogScheduler) where Sink: LogSink, Sink.Input == Input, Sink.Output == Output {
            self.sink = AnyLogSink(sink)
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
