import Logging

public protocol LogOutputStream {
    
    associatedtype Output
        
    func write(_ logEntry: @autoclosure () throws -> ProcessedLogEntry<Output>) rethrows
}
