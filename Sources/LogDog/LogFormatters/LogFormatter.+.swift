public func +<A, B, C>(_ f1: LogFormatter<A, B>, _ f2: LogFormatter<B, C>) -> LogFormatter<A, C> {
    LogFormatter {
        let logEntry = try f1.format($0)
        return try f2.format(logEntry)
    }
}

