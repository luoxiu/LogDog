import Foundation
import Logging
import Backtrace

public final class LogEntry: Encodable {
    
    public let label: String
    
    public let level: Logger.Level
    
    public let message: Logger.Message
    
    public let metadata: Logger.Metadata
    
    public let file: String
    
    public let function: String
    
    public let line: UInt
    
    public let date: Date
    
    public let threadId: String
    
    public let threadName: String?
    
    public let dispatchQueueLabel: String?
    
    public let backtrace: [StackFrame]
        
    public init(label: String,
                level: Logger.Level,
                message: Logger.Message,
                metadata: Logger.Metadata,
                file: String,
                function: String,
                line: UInt,
                date: Date,
                threadId: String,
                threadName: String?,
                dispatchQueueLabel: String?,
                backtrace: [StackFrame]
    ) {
        self.label = label
        self.level = level
        self.message = message
        self.metadata = metadata
        self.file = file
        self.function = function
        self.line = line
        self.date = date
        self.threadId = threadId
        self.threadName = threadName
        self.dispatchQueueLabel = dispatchQueueLabel
        self.backtrace = backtrace
    }
}
