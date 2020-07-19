import Foundation

public struct LogDogLogHandler<Processor, OutputStream>: LogHandler where Processor: LogProcessor, OutputStream: LogOutputStream, Processor.Input == Void, Processor.Output == OutputStream.Output {
    public var logLevel: Logger.Level = .trace
    
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
    
    public let processor: Processor
    public let outputStream: OutputStream
    
    public var queue: DispatchQueue?
    public var errorHandler: ((Error) -> Void)?
    
    public init(label: String, processor: Processor, outputStream: OutputStream) {
        self.label = label
        self.processor = processor
        self.outputStream = outputStream
        
        self.flushAtExit()
    }
}

extension LogDogLogHandler {
    
    var metadataSnapshot: Logger.Metadata {
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
        
        let logEntry = LogEntry(label: label,
                                level: level,
                                message: message,
                                metadata: finalMetadata,
                                source: source, file: file, function: function, line: line,
                                date: Date(),
                                context: [:])
        
        let finalContext = processor
            .contextCaptures
            .compactMapValues {
                $0(logEntry)?.metadataValue
            }
        
        logEntry.context = finalContext
        
        let processAndOutput = {
            do {
                let processed = try self.processor.process(logEntry)
                try self.outputStream.output(processed)
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

private extension Notification.Name {
    static let atExit = Notification.Name(rawValue: "com.v2ambition.LogDog.LogDogLogHandler.atExit")
    
    static let registerAtExit = {
        atexit {
            NotificationCenter.default.post(name: .atExit, object: nil)
        }
    }()
}

extension LogDogLogHandler {
    
    private func flushAtExit() {
        let flush = {
            self.queue?.sync {}
        }
        
        var name = Notification.Name.appWillTerminate
        
        if name == nil {
            _ = Notification.Name.registerAtExit
            name = Notification.Name.atExit
        }
        
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
            flush()
        }
    }
}
