public typealias LogHook = (LogEntry) -> Void

extension Array where Element == LogHook {
    
    public mutating func use(_ hook: @escaping LogHook) {
        append(hook)
    }
    
    public func hook(_ entry: LogEntry) {
        forEach {
            $0(entry)
        }
    }
}
