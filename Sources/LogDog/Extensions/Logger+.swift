import Logging

extension Logger {
    
    public init<Output, OutputStream>(
        label: String,
        level: Logger.Level = .trace,
        metadata: Logger.Metadata = [:],
        processor: LogProcessor<Void, Output>,
        outputStream: OutputStream
    )
        where OutputStream: LogOutputStream, OutputStream.Output == Output
    {
        var logger = Logger(label: label) { label -> LogHandler in
            LogDogLogHandler(label: label, processor: processor, outputStream: outputStream)
        }
        
        logger.logLevel = level
        
        self = logger
    }
    
    public init(
        label: String,
        level: Logger.Level = .trace,
        metadata: Logger.Metadata = [:],
        processor: LogProcessor<Void, String>
    )
    {
        self.init(label: label, level: level, metadata: metadata, processor: processor, outputStream: StdoutLogOutputStream())
    }
}
