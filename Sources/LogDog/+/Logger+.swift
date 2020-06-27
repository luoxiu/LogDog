import Logging

extension Logger {
    
    public init<Formatter, OutputStream>(
        label: String,
        level: Logger.Level = .trace,
        metadata: Logger.Metadata = [:],
        formatter: Formatter,
        outputStream: OutputStream
    )
        where Formatter: LogFormatter, OutputStream: LogOutputStream,
        Formatter.I == Void, Formatter.O == OutputStream.Output
    {
        var logger = Logger(label: label) { label -> LogHandler in
            OutputStreamLogHandler(label: label, formatter: formatter, outputStream: outputStream)
        }
        
        logger.logLevel = level
        
        self = logger
    }
    
    public init<Formatter>(
        label: String,
        level: Logger.Level = .trace,
        metadata: Logger.Metadata = [:],
        formatter: Formatter
    )
        where Formatter: LogFormatter, Formatter.I == Void, Formatter.O == String
    {
        self.init(label: label, level: level, metadata: metadata, formatter: formatter, outputStream: StdoutLogOutputStream())
    }
}
