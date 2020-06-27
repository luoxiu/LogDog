import Logging

public protocol LogOutputStream {
    
    associatedtype Output
        
    func write(_ log: @autoclosure () throws -> Log<Output>) rethrows
}
