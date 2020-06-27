import Logging

public struct StdoutLogOutputStream: LogOutputStream {
    
    public init() { }
    
    public func write(_ log: @autoclosure () throws -> Log<String>) rethrows {
        let l = try log()
        print(l.output)
    }
}
