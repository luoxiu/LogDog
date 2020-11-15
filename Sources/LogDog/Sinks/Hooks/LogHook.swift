import Foundation

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
        .init {
            hook(&$0)
            other.hook(&$0)
        }
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
