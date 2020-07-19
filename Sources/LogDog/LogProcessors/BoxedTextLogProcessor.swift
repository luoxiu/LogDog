///// inspired by https://github.com/orhanobut/logger
public struct BoxedTextLogProcessor: LogProcessor {
    
    public typealias Input = Void
    public typealias Output = String
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public let rowWidth: Int
    public let showDate: Bool
    public let showThread: Bool
    public let showLocation: Bool
    
    public init(
        rowWidth: Int = 80,
        showDate: Bool = false,
        showThread: Bool = false,
        showLocation: Bool = false
    ) {
        self.rowWidth = rowWidth
        self.showDate = showDate
        self.showThread = showThread
        self.showLocation = showLocation
        
        if showThread {
            self.register(.currentThreadId)
            self.register(.currentThreadName)
            self.register(.currentDispatchQueueLabel)
        }
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Void>) throws -> ProcessedLogEntry<String> {
        let topBorder = "┌" + repeatElement("─", count: self.rowWidth)
        let bottomBorder = "└" + repeatElement("─", count: self.rowWidth)
        let horizontalDivider = "├" + repeatElement("┄", count: self.rowWidth)
        
        let entry = logEntry.rawLogEntry
        
        let prefix = "\(entry.label):\(entry.level.output(.initial)) "
        
        var message = ""
        
        func output(_ line: String) {
            message += prefix
            message += "│ "
            message += line
            message += "\n"
        }
        
        func outputHorizontalDivider() {
            message += prefix
            message += horizontalDivider
            message += "\n"
        }
        
        func outputTopBorder() {
            message += prefix
            message += topBorder
            message += "\n"
        }
        
        func outputBottomBorder() {
            message += prefix
            message += bottomBorder
        }
        
        outputTopBorder()
        
        if self.showDate {
            output(entry.date.iso8601String)
            outputHorizontalDivider()
        }
        
        if self.showThread {
            let threadId = entry.get(.currentThreadId)
            let threadName = entry.get(.currentThreadName)
            let dispatchQueueLabel = entry.get(.currentDispatchQueueLabel)
            
            var thread = ""
            if let threadName = threadName, threadName.count > 0 {
                thread = "Thread \(threadName)"
            } else if let label = dispatchQueueLabel, label.count > 0 {
                thread = label
            } else {
                thread = "Thread \(threadId as Any)"
            }
            
            output(thread)
            outputHorizontalDivider()
        }
        
        if self.showLocation {
            output("\(entry.file.lastPathComponent):\(entry.line) \(entry.function)")
            outputHorizontalDivider()
        }
        
        entry.message.description.enumerateLines { line, _ in
            output(line)
        }
        
        if entry.metadata.isEmpty {
            outputBottomBorder()
        } else {
            outputHorizontalDivider()
            
            output("{")
            
            for (k, v) in entry.metadata {
                output("    \(k): \(v)")
            }
            
            output("}")
            
            outputBottomBorder()
        }
        
        return .init(entry, message)
    }
}
