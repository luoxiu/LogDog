import Dispatch

open class StdoutLogOutputStream: LogOutputStream {
    
    public init() { }
    
    public let queue = DispatchQueue(label: "com.v2ambition.LogDog.StdoutLogOutputStream")
    
    open func output(_ logEntry: ProcessedLogEntry<String>) throws {
        let output = logEntry.output
        
        queue.sync {
            print(output)
        }
    }
}
