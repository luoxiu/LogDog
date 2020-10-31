import Foundation

public struct SugarLogHandler<Processor, Appender>: LogHandler where Processor: LogFormatter, Appender: LogAppender, Processor.Input == Void, Processor.Output == Appender.Output {
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
    
    public let processor: Processor
    public let appender: Appender
    
    public var queue: DispatchQueue?
    public var errorHandler: ((Error) -> Void)?
    
    public init(label: String, processor: Processor, appender: Appender) {
        self.label = label
        self.processor = processor
        self.appender = appender
    }
    
    public func flush() {
        queue?.sync { }
    }
}

extension SugarLogHandler {
    
    var metadataSnapshot: Logger.Metadata {
        dynamicMetadata
            .mapValues { $0() }
            .merging(metadata, uniquingKeysWith: { a, _ in a })
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
        if let metadata = metadata {
            finalMetadata.merge(metadata, uniquingKeysWith: { _, b in b })
        }
        
        let logEntry = LogEntry(label: label,
                                level: level,
                                message: message,
                                metadata: finalMetadata,
                                source: source, file: file, function: function, line: line,
                                date: Date(),
                                context: [:])
        
        let finalContext = processor
            .context
            .compactMapValues {
                $0()
            }
        
        logEntry.context = finalContext
        
        let processAndOutput = {
            do {
                let processed = try self.processor.process(logEntry)
                try self.appender.append(processed)
            } catch {
                self.errorHandler?(error)
            }
        }
        
        if let queue = self.queue {
            queue.async(execute: processAndOutput)
        } else {
            processAndOutput()
        }
    }
}
