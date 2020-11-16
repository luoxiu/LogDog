public struct LogEntry {
    // Avoid copy.
    private final class Storage {
        let label: String

        let level: Logger.Level

        let message: Logger.Message

        let metadata: Logger.Metadata

        let source: String

        let file: String

        let function: String

        let line: UInt

        init(label: String,
             level: Logger.Level,
             message: Logger.Message,
             metadata: Logger.Metadata,
             source: String,
             file: String,
             function: String,
             line: UInt)
        {
            self.label = label
            self.level = level
            self.message = message
            self.metadata = metadata
            self.source = source
            self.file = file
            self.function = function
            self.line = line
        }
    }

    private let storage: Storage

    public var label: String { storage.label }

    public var level: Logger.Level { storage.level }

    public var message: Logger.Message { storage.message }

    public var metadata: Logger.Metadata { storage.metadata }

    public var source: String { storage.source }

    public var file: String { storage.file }

    public var function: String { storage.function }

    public var line: UInt { storage.line }

    public var parameters: LogParameters

    public init(label: String,
                level: Logger.Level,
                message: Logger.Message,
                metadata: Logger.Metadata,
                source: String,
                file: String,
                function: String,
                line: UInt,
                parameters: LogParameters = LogParameters())
    {
        storage = .init(label: label,
                        level: level,
                        message: message,
                        metadata: metadata,
                        source: source,
                        file: file,
                        function: function,
                        line: line)

        self.parameters = parameters
    }
}
