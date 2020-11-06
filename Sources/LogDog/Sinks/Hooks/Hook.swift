public extension LogSink {
    func hook(_ hook: @escaping (LogEntry) -> Void) -> LogHooks.Hook<Self> {
        .init(self, LogHook(hook))
    }

    func hook(_ hook: LogHook) -> LogHooks.Hook<Self> {
        .init(self, hook)
    }

    func hook(_ hooks: LogHook...) -> LogHooks.Hook<Self> {
        .init(self, LogHook(hooks))
    }

    func hook(_ hooks: [LogHook]) -> LogHooks.Hook<Self> {
        .init(self, LogHook(hooks))
    }
}

public extension LogHooks {
    struct Hook<Sink: LogSink>: LogSink {
        public typealias Input = Sink.Input
        public typealias Output = Sink.Output

        private let sink: Sink
        private let hook: LogHook

        public init(_ sink: Sink, _ hook: LogHook) {
            self.sink = sink
            self.hook = hook
        }

        public func beforeSink(_ entry: LogEntry) {
            hook.hook(entry)
        }

        public func sink(_ record: LogRecord<Sink.Input>, next: @escaping (Result<LogRecord<Sink.Output>?, Error>) -> Void) {
            sink.sink(record, next: next)
        }
    }
}
