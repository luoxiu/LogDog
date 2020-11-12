public struct LogEntry {
    
    public final class Storage {
        
        public let label: String

        public let level: Logger.Level

        public let message: Logger.Message

        public let metadata: Logger.Metadata

        public let source: String

        public let file: String

        public let function: String

        public let line: UInt
        
        public init(label: String,
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

    /// When using json formatting, all key-value pairs in the dictionary whose key is string and value is codable will be selected and encoded.
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
        self.storage = .init(label: label,
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
