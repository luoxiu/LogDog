import Foundation

public final class StopwatchLogFormatter: LogFormatter {
    
    public typealias I = Void
    public typealias O = String
    
    private var last: Date?
    
    public init() {
    }
    
    public func format(_ log: FormattedLogEntry<Void>) throws -> FormattedLogEntry<String> {
        let rawLog = log.rawLog
        
        var interval: TimeInterval = 0
        if let last = self.last {
            interval = Date().timeIntervalSince(last)
        }
        self.last = Date()
        
        let message = "\(rawLog.label):\(rawLog.level.output(.initial)) \(rawLog.message) \(interval.formatted)"
        return FormattedLogEntry(rawLog, message)
    }
}
