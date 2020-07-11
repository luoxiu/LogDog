import Foundation

open class StopwatchLogProcessor: LogProcessor<Void, String> {

    public init() {
        var last: Date?
        
        super.init {
            let rawLog = $0.raw
            
            var interval: TimeInterval = 0
            if let last = last {
                interval = Date().timeIntervalSince(last)
            }
            last = Date()
            
            let message = "\(rawLog.label):\(rawLog.level.output(.initial)) \(rawLog.message) \(interval.formatted)"
            return ProcessedLogEntry(rawLog, message)
        }
    }
}
