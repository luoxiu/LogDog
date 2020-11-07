import Foundation

public struct LogHook {
    private let body: (LogEntry) -> Void

    public init(_ hook: @escaping (LogEntry) -> Void) {
        body = hook
    }

    public init(_ hooks: [LogHook]) {
        body = { entry in
            hooks.forEach {
                $0.hook(entry)
            }
        }
    }

    public func hook(_ entry: LogEntry) {
        body(entry)
    }
}

extension LogHook {
    func concat(_ other: LogHook) -> LogHook {
        .init {
            hook($0)
            other.hook($0)
        }
    }
}

public extension LogHook {
    // MAKR: App
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
        var thread = Thread.current.name ?? LogHelper.currentThreadID ?? LogHelper.currentDispatchQueueLabel
        $0.parameters["thread"] = thread
    }
}
