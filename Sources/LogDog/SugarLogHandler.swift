/// Global shared logger.
public let sugar = Logger.sugar("app")

public extension Logger {
    static func sugar(_ label: String) -> Logger {
        Logger(label: label) {
            SugarLogHandler(label: $0,
                            sink: LogSinks.BuiltIn.long.suffix("\n"),
                            appender: TextLogAppender.stdout)
        }
    }
}

public struct SugarLogHandler<Sink, Appender>: LogHandler where Sink: LogSink, Appender: LogAppender, Sink.Input == Void, Sink.Output == Appender.Output {
    public var logLevel: Logger.Level = .trace

    public var metadata: Logger.Metadata = [:]

    /// dynamic metadata values override metadata values.
    public var dynamicMetadata: [String: () -> Logger.MetadataValue] = [:]

    public let label: String

    public let sink: Sink
    public let appender: Appender

    private let errorHandler: ((Error) -> Void)?

    public init(label: String,
                sink: Sink,
                appender: Appender,
                errorHandler: ((Error) -> Void)? = nil)
    {
        self.label = label

        self.sink = sink
        self.appender = appender

        self.errorHandler = errorHandler
    }
}

public extension SugarLogHandler {
    func log(level: Logger.Level,
             message: Logger.Message,
             metadata: Logger.Metadata?,
             source: String,
             file: String,
             function: String,
             line: UInt)
    {
        var finalMetadata = self.metadata

        for (key, value) in dynamicMetadata {
            finalMetadata[key] = value()
        }

        if let metadata = metadata {
            finalMetadata.merge(metadata, uniquingKeysWith: { _, b in b })
        }

        var entry = LogEntry(label: label,
                             level: level,
                             message: message,
                             metadata: finalMetadata,
                             source: source,
                             file: file,
                             function: function,
                             line: line)

        sink.beforeSink(&entry)

        let record = LogRecord(entry, ())

        sink.sink(record) { result in

            switch result {
            case let .success(newRecord):
                do {
                    try newRecord.map {
                        try appender.append($0)
                    }
                } catch {
                    errorHandler?(error)
                }
            case let .failure(error):
                errorHandler?(error)
            }
        }
    }
}
