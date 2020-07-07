public protocol LogFormatter {
    
    associatedtype I
    associatedtype O
    
    func format(_ logEntry: FormattedLogEntry<I>) throws -> FormattedLogEntry<O>
}

extension LogFormatter where I == Void {
    
    func format(_ logEntry: LogEntry) throws -> FormattedLogEntry<O> {
        try format(FormattedLogEntry(logEntry, ()))
    }
}
