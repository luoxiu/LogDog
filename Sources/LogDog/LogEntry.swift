import Foundation
import Logging
import Backtrace

public final class LogEntry: Encodable {
    
    public let label: String
    
    public let level: Logger.Level
    
    public let message: Logger.Message
    
    public let metadata: Logger.Metadata
    
    public let source: String
    
    public let file: String
    
    public let function: String
    
    public let line: UInt
    
    public let date: Date

    public let context: Context
        
    public init(label: String,
                level: Logger.Level,
                message: Logger.Message,
                metadata: Logger.Metadata,
                source: String,
                file: String,
                function: String,
                line: UInt,
                date: Date,
                context: Context
    ) {
        self.label = label
        self.level = level
        self.message = message
        self.metadata = metadata
        self.source = source
        self.file = file
        self.function = function
        self.line = line
        self.date = date
        self.context = context
    }
}
