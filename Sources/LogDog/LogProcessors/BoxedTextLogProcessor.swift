///// inspired by https://github.com/orhanobut/logger
public struct BoxedTextLogProcessor: LogProcessor {
    
    public typealias Input = Void
    public typealias Output = String
    
    public var contextCaptures: [String : () -> LossLessMetadataValueConvertible?] = [:]
    
    public let rowWidth: Int
    public let showDate: Bool
    public let showThreadInfo: Bool
    public let methodCount: Int
    public let methodOffset: Int
    
    public init(
        rowWidth: Int = 70,
        showDate: Bool = false,
        showThreadInfo: Bool = false,
        methodCount: Int = 0,
        methodOffset: Int = 16
    ) {
        
        self.rowWidth = rowWidth
        self.showDate = showDate
        self.showThreadInfo = showThreadInfo
        self.methodCount = methodCount
        self.methodOffset = methodOffset
        
        if showThreadInfo {
            self.register(.currentThreadId)
            self.register(.currentThreadName)
            self.register(.currentDispatchQueueLabel)
        }
        
        if methodCount > 0 {
            self.register(.backtrace)
        }
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Void>) throws -> ProcessedLogEntry<String> {
        let topBorder = "┌" + repeatElement("─", count: rowWidth)
        let bottomBorder = "└" + repeatElement("─", count: rowWidth)
        let horizontalDivider = "├" + repeatElement("┄", count: rowWidth)
        
        let rawLogEntry = logEntry.rawLogEntry
        
        let prefix = "\(rawLogEntry.label):\(rawLogEntry.level.output(.initial)) "
        
        var message = ""
        
        func output(_ line: String) {
            message += prefix
            message += "| "
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
        
        if showDate {
            output(rawLogEntry.date.iso8601String)
            outputHorizontalDivider()
        }
        
        if showThreadInfo {
            let threadId = rawLogEntry.get(.currentThreadId)
            let threadName = rawLogEntry.get(.currentThreadName)
            let dispatchQueueLabel = rawLogEntry.get(.currentDispatchQueueLabel)
            
            var threadInfo = ""
            if let threadName = threadName, threadName.count > 0 {
                threadInfo = "Thread \(threadName)"
            } else if let label = dispatchQueueLabel, label.count > 0 {
                threadInfo = label
            } else {
                threadInfo = "Thread \(threadId as Any)"
            }
            
            output(threadInfo)
            outputHorizontalDivider()
        }
        
        if methodCount > 0 {
            let backtrace = rawLogEntry.get(.backtrace) ?? []
            let backtraceToLog = backtrace[safe: methodOffset ..< (methodOffset + methodCount)]
            backtraceToLog
                .map {
                    $0.resolvedFunctionName(using: .simplified)
                }
                .enumerated().forEach { i, line in
                    var s = String(repeating: " ", count: i * 4) + line
                    if i == 0 {
                        s += " - \(rawLogEntry.file.lastPathComponent.deletingPathExtension):\(rawLogEntry.line)"
                    }
                    output(s)
                }
            outputHorizontalDivider()
        }
        
        rawLogEntry.message.description.enumerateLines { line, _ in
            output(line)
        }
        
        if rawLogEntry.metadata.isEmpty {
            outputBottomBorder()
        } else {
            outputHorizontalDivider()
            
            output("{")
            
            for (k, v) in rawLogEntry.metadata {
                output("    \"\(k)\": \(v)")
            }
            
            output("}")
            
            outputBottomBorder()
        }
        
        return .init(rawLogEntry, message)
    }
}


