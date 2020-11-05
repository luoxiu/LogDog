import Foundation

extension Logger {
    
    public static func sugar(_ label: String) -> Logger {
        Logger(label: label) {
            SugarLogHandler(label: $0,
                            formatter: TextLogFormatter.default,
                            appender: TextLogAppender.stdout)
        }
    }
}

public struct SugarLogHandler<Formatter, Appender>: LogHandler where Formatter: LogFormatter, Appender: LogAppender, Formatter.Input == Void, Formatter.Output == Appender.Output {
    
    public var logLevel: Logger.Level = .trace
    
    public var metadata: Logger.Metadata = [:]
    
    /// dynamic metadata values override metadata values.
    public var dynamicMetadata: [String: () -> Logger.MetadataValue] = [:]
    
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
                             file: file.basename,
                             function: function,
                             line: line)
        
        if let hooks = formatter.hooks {
            for i in hooks.indices {
                hooks[i].hook(entry)
            }
        }
        
        let formatAndAppend = {
            do {
                let record = LogRecord(entry, ())
                if let newRecord = try record.formatted(by: formatter) {
                    try appender.append(newRecord)
                }
            } catch {
                errorHandler?(error)
            }
        }
        
        formatAndAppend()
    }
}
