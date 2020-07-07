import struct Foundation.Date
import Logging
import Backtrace

public struct LogDogLogHandler<Formatter, OutputStream>: LogHandler where Formatter: LogFormatter, OutputStream: LogOutputStream, Formatter.I == Void, Formatter.O == OutputStream.Output {
    public var logLevel: Logger.Level = .info

    public typealias DynamicMetadataValue = () -> Logger.MetadataValue
    
    public typealias DynamicMetadata = [String: DynamicMetadataValue]
    
    public var metadata: Logger.Metadata = [:]
    
    public var dynamicMetadata: DynamicMetadata = [:]

    public subscript(metadataKey metadataKey: String) -> Logger.MetadataValue? {
        get {
            metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
        }
    }
    
    /// Please note: dynamic metadata values override metadata values.
    public subscript(metadataKey metadataKey: String) -> DynamicMetadataValue? {
        get {
            dynamicMetadata[metadataKey]
        }
        set(newValue) {
            dynamicMetadata[metadataKey] = newValue
        }
    }
    
    public let label: String
    
    public let formatter: Formatter
    public let outputStream: OutputStream
    
    public init(label: String, formatter: Formatter, outputStream: OutputStream) {
        self.label = label
        self.formatter = formatter
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
        
        let rawLog = LogEntry(label: label,
            level: level,
            message: message,
            metadata: finalMetadata,
            file: file, function: function, line: line,
            date: Date(),
            threadId: Utils.currentThreadId,
            threadName: Utils.currentThreadName,
            dispatchQueueLabel: Utils.currentDispatchQueueLabel,
            backtrace: backtrace())

        do {
            try outputStream.write(try formatter.format(FormattedLogEntry(rawLog, ())))
        } catch {
            print("LOGDOG: \(error)")
        }
    }
}
