import Foundation

public struct SugarLogHandler<Formatter, Appender>: LogHandler where Formatter: LogFormatter, Appender: LogAppender, Formatter.Input == Void, Formatter.Output == Appender.Output {
    public var logLevel: Logger.Level = .trace
    
    public var metadata: Logger.Metadata = [:]
    
    /// dynamic metadata values override metadata values.
    public var dynamicMetadata: [String: () -> Logger.MetadataValue] = [:]
    
    public subscript(metadataKey metadataKey: String) -> Logger.MetadataValue? {
        get {
            metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
        }
    }
    
    public let label: String
    
    public let formatter: Formatter
    public let appender: Appender
    
    private let errorHandler: ((Error) -> Void)?
    
    public init(label: String,
                formatter: Formatter,
                appender: Appender,
                errorHandler: ((Error) -> Void)? = nil) {
        self.label = label
        
        self.formatter = formatter
        self.appender = appender
        
        self.errorHandler = errorHandler
    }
}

extension SugarLogHandler {
    
    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        
        var finalMetadata = self.metadata
        
        for (key, value) in self.dynamicMetadata {
            finalMetadata[key] = value()
        }
        
        if let metadata = metadata {
            finalMetadata.merge(metadata, uniquingKeysWith: { _, b in b })
        }
        
        let entry = LogEntry(label: label,
                             level: level,
                             message: message,
                             metadata: finalMetadata,
                             source: source,
                             file: file,
                             function: function,
                             line: line)
        
        formatter.hooks?.hook(entry)
        
        do {
            let record = LogRecord(entry, ())
            if let newRecord = try record.formatted(by: formatter) {
                try appender.append(newRecord)
            }
        } catch {
            errorHandler?(error)
        }
    }
}
