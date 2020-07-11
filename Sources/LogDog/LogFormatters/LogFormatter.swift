open class LogFormatter<Input, Output> {
    
    open var dynamicContext: [String: () -> MetadataValueConvertible]
    
    private let transform: (FormattedLogEntry<Input>) throws -> FormattedLogEntry<Output>
    
    public init(_ transform: @escaping (FormattedLogEntry<Input>) throws -> FormattedLogEntry<Output>) {
        self.dynamicContext = [:]
        self.transform = transform
    }
    
    open func format(_ logEntry: FormattedLogEntry<Input>) throws -> FormattedLogEntry<Output> {
        try transform(logEntry)
    }
}

extension LogFormatter where Input == Void {
    
    open func format(_ logEntry: LogEntry) throws -> FormattedLogEntry<Output> {
        try format(FormattedLogEntry(logEntry, ()))
    }
}
