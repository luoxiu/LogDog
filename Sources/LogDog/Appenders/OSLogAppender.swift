import Foundation
#if canImport(os)
    import os

    /// Appends string-records to the underlying OSLog object.
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public struct OSLogAppender: LogAppender {
        public let osLog: OSLog

        public init(osLog: OSLog = .default) {
            self.osLog = osLog
        }

        public init(subsystem: String, category: String) {
            osLog = OSLog(subsystem: subsystem, category: category)
        }

        public func append(_ record: LogRecord<String>) throws {
            // TODO: use os.Logger on iOS 14+ / macOS 11+.
            // HELP WANTED! 🙋‍♂️

            // The following level conversion adopts os.Logger.

            var type: OSLogType = .default
            switch record.entry.level {
            case .critical:
                type = .fault
            case .error, .warning:
                type = .error
            case .notice:
                type = .default
            case .info:
                type = .info
            case .debug, .trace:
                type = .debug
            }

            os_log("%{public}s", log: osLog, type: type, record.output)
        }
    }
#endif
