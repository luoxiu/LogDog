import Logging

extension Logger {
    
    public init<Processor, OutputStream>(
        label: String,
        level: Logger.Level = .trace,
        metadata: Logger.Metadata = [:],
        processor: Processor,
        outputStream: OutputStream
    )
    where Processor: LogProcessor, OutputStream: LogOutputStream, Processor.Input == Void, Processor.Output == OutputStream.Output
    {
        var logger = Logger(label: label) { label -> LogHandler in
            LogDogLogHandler(label: label, processor: processor, outputStream: outputStream)
        }
        
        logger.logLevel = level
        
        self = logger
    }
}
