import struct Foundation.Date
import Logging
import Backtrace

public struct OutputStreamLogHandler<Formatter, OutputStream>
    : LogHandler
    where Formatter: LogFormatter, OutputStream: LogOutputStream,
    Formatter.I == Void, Formatter.O == OutputStream.Output
{

    public var logLevel: Logger.Level = .info
    
    public var metadata: Logger.Metadata = [:]

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
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

extension OutputStreamLogHandler {

    public func log(level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt) {
        
        var _metadata = self.metadata
        if let metadata = metadata {
            _metadata.merge(metadata, uniquingKeysWith: { _, b in b })
        }
        
        let rawLog = RawLog(label: label,
            level: level,
            message: message,
            metadata: _metadata,
            file: file, function: function, line: line,
            date: Date(),
            threadId: Utils.currentThreadId,
            threadName: Utils.currentThreadName,
            dispatchQueueLabel: Utils.currentDispatchQueueLabel,
            backtrace: backtrace())

        do {
            try outputStream.write(try formatter.format(Log(rawLog, ())))
        } catch {
            print("LOGDOG: \(error)")
        }
    }
}
