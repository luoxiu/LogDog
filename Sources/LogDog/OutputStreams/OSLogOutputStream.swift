import os

@available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public struct OSLogOutputStream: LogOutputStream {
    
    public let osLog: OSLog
    
    public init(osLog: OSLog = .default) {
        self.osLog = osLog
    }
    
    public init(subsystem: String, category: String) {
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    public func write(_ log: Log<String>) {
        var type: OSLogType = .default
        switch log.rawLog.level {
        case .critical:
            type = .fault
        case .error:
            type = .error
        case .warning, .notice, .info:
            type = .default
        case .debug, .trace:
            type = .debug
        }
        os_log("%{public}s", log: osLog, type: type, log.output)
    }
}
