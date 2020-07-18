import Logging

public protocol LogOutputStream {
    
    associatedtype Output
        
    func write(_ logEntry: ProcessedLogEntry<Output>) throws
}
