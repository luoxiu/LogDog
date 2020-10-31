import Dispatch

open class StdoutLogAppender: LogAppender {
    
    public init() { }
    
    public let queue = DispatchQueue(label: "com.v2ambition.LogDog.StdoutLogAppender")
    
    open func append(_ logEntry: ProcessedLogEntry<String>) throws {
        let output = logEntry.output
        
        queue.sync {
            print(output)
        }
    }
}
