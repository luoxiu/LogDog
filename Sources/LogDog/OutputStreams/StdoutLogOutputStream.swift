import Logging

public struct StdoutLogOutputStream: LogOutputStream {
    
    public init() { }
    
    public func write(_ log: Log<String>) {
        print(log.output)
    }
}
