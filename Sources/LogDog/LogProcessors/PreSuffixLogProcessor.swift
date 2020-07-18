public struct PreSuffixLogProcessor: LogProcessor {
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public typealias Input = String
    public typealias Output = String
    
    public let prefix: String
    public let suffix: String
    
    public init(prefix: String, suffix: String) {
        self.prefix = prefix
        self.suffix = suffix
    }
    
    public func process(_ logEntry: ProcessedLogEntry<String>) throws -> ProcessedLogEntry<String> {
        logEntry.map { string in
            prefix + string + suffix
        }
    }
}
