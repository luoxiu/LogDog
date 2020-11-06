import Foundation

public extension LogSink {
    func schedule(on scheduler: LogScheduler) -> LogSinks.Schedule<Input, Output> {
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
                self.sink.sink(record, next: next)
            }
        }
    }
}
