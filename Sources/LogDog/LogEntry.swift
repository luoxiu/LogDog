public final class LogEntry {
    public let label: String
    
    public let level: Logger.Level
    
    public let message: Logger.Message
    
    public let metadata: Logger.Metadata
    
    public let source: String
    
    public let file: String
    
    public let function: String
    
    public let line: UInt
    
    public var parameters: LogParameters
    
    public init(label: String,
                level: Logger.Level,
                message: Logger.Message,
                metadata: Logger.Metadata,
                source: String,
                file: String,
                function: String,
                line: UInt,
                parameters: LogParameters = LogParameters()
    ) {
        self.label = label
        self.level = level
        self.message = message
        self.metadata = metadata
        self.source = source
        self.file = file
        self.function = function
        self.line = line
        self.parameters = parameters
    }
}
