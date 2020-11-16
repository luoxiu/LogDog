import Foundation

public extension LogSink {
    func hook(_ hook: @escaping (inout LogEntry) -> Void)
        -> LogSinks.Concat<Self, LogSinks.Hook<Output>>
    {
        self + .init(hook: LogHook(hook))
    }

    func hook(_ hook: LogHook)
        -> LogSinks.Concat<Self, LogSinks.Hook<Output>>
    {
        self + .init(hook: hook)
    }
}

public extension LogSink {
    func hook(_ hooks: LogHook...)
        -> LogSinks.Concat<Self, LogSinks.Hook<Output>>
    {
        self + .init(hook: LogHook(hooks))
    }

    func hook(_ hooks: [LogHook])
        -> LogSinks.Concat<Self, LogSinks.Hook<Output>>
    {
        self + .init(hook: LogHook(hooks))
    }
}

public extension LogSinks {
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

// MARK: LogHook

public struct LogHook {
    private let body: (inout LogEntry) -> Void

    public init(_ hook: @escaping (inout LogEntry) -> Void) {
        body = hook
    }

    public func hook(_ entry: inout LogEntry) {
        body(&entry)
    }
}

extension LogHook {
    public init(_ hooks: [LogHook]) {
        body = { entry in
            hooks.forEach {
                $0.hook(&entry)
            }
        }
    }

    func concat(_ other: LogHook) -> LogHook {
        LogHook([self, other])
    }
}

// MARK: - common hooks

public extension LogHook {
    // MARK: App

    static let appBuild = LogHook {
        $0.parameters["appBuild"] = LogHelper.appBuild
    }

    static let appName = LogHook {
        $0.parameters["appName"] = LogHelper.appName
    }

    static let appVersion = LogHook {
        $0.parameters["appVersion"] = LogHelper.appVersion
    }

    // MARK: Data

    static let date = LogHook {
        $0.parameters["date"] = Date()
    }

    // MARK: Thread

    static let thread = LogHook {
        $0.parameters["thread"] = LogHelper.thread
    }
}
