import Logging

public protocol LogOutputStream {
    
    associatedtype Output
        
    func write(_ log: Log<Output>) throws
}
