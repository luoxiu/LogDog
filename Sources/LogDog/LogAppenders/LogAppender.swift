import Logging

public protocol LogAppender {
    
    associatedtype Output
        
    func append(_ logEntry: ProcessedLogEntry<Output>) throws
}
