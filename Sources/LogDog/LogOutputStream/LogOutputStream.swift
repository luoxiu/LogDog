import Logging

public protocol LogOutputStream {
    
    associatedtype Output
        
    func output(_ logEntry: ProcessedLogEntry<Output>) throws
}
