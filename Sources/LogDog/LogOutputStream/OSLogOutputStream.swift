import os
import Foundation

@available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
open class OSLogOutputStream: LogOutputStream {
    
    public let osLog: OSLog
    
    public let queue = DispatchQueue(label: "com.v2ambition.LogDog.StdoutLogOutputStream")
    
    public init(osLog: OSLog = .default) {
        self.osLog = osLog
    }
    
    public init(subsystem: String, category: String) {
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    open func output(_ logEntry: ProcessedLogEntry<String>) throws {
        let level = logEntry.rawLogEntry.level
        let output = logEntry.output
        
        var type: OSLogType = .default
        switch level {
        case .critical:
            type = .fault
        case .error:
            type = .error
        case .warning, .notice, .info:
            type = .default
        case .debug, .trace:
            type = .debug
        }
        
        queue.sync {
            os_log("%{public}s", log: osLog, type: type, output)
        }
    }
}
