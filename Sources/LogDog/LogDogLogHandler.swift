import struct Foundation.Date
import Logging
import Backtrace

public struct LogDogLogHandler<Output, OutputStream>: LogHandler where OutputStream: LogOutputStream, OutputStream.Output == Output {
    public var logLevel: Logger.Level = .info
    
    public var metadata: Logger.Metadata = [:]
    
    /// Please note: dynamic metadata values override metadata values.
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
    
    public let processor: LogProcessor<Void, Output>
    public let outputStream: OutputStream
    
    public init(label: String, processor: LogProcessor<Void, Output>, outputStream: OutputStream) {
        self.label = label
        self.processor = processor
        self.outputStream = outputStream
    }
}

extension LogDogLogHandler {
    
    public var metadataSnapshot: Logger.Metadata {
        dynamicMetadata
            .mapValues { $0() }
            .merging(metadata, uniquingKeysWith: { a, _ in a })
    }
}

extension LogDogLogHandler {

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
        
        let finalContext = processor.contextSnapshot
        
        let logEntry = LogEntry(label: label,
                                level: level,
                                message: message,
                                metadata: finalMetadata,
                                source: source, file: file, function: function, line: line,
                                date: Date(),
                                context: finalContext)

        do {
            let formatted = try processor.process(logEntry)
            outputStream.write(formatted)
        } catch {
            
        }
    }
}
