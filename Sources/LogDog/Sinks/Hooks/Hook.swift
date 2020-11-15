public extension LogSink {
    func hook(_ hook: @escaping (inout LogEntry) -> Void)
        -> LogSinks.Concat<Self, LogHooks.Hook<Output>>
    {
        self + .init(hook: LogHook(hook))
    }

    func hook(_ hook: LogHook)
        -> LogSinks.Concat<Self, LogHooks.Hook<Output>>
    {
        self + .init(hook: hook)
    }
}

public extension LogSink {
    func hook(_ hooks: LogHook...)
        -> LogSinks.Concat<Self, LogHooks.Hook<Output>>
    {
        self + .init(hook: LogHook(hooks))
    }

    func hook(_ hooks: [LogHook])
        -> LogSinks.Concat<Self, LogHooks.Hook<Output>>
    {
        self + .init(hook: LogHook(hooks))
    }
}

public extension LogHooks {
    struct Hook<Input>: LogSink {
        public typealias Output = Input

        public let hook: LogHook

        public init(hook: LogHook) {
            self.hook = hook
        }

        public func beforeSink(_ entry: inout LogEntry) {
            hook.hook(&entry)
        }
    }
}
