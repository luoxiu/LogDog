import Logging

public protocol LogAppender {
    
    associatedtype Output
        
    func output(_ logEntry: ProcessedLogEntry<Output>) throws
}
