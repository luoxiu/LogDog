///// inspired by https://github.com/orhanobut/logger
open class BoxedTextLogProcessor: TextLogProcessor {
    
    public init(
        rowWidth: Int = 70,
        showDate: Bool = false,
        showThreadInfo: Bool = false,
        methodCount: Int = 0,
        methodOffset: Int = 16
    ) {
        let topBorder = "┌" + repeatElement("─", count: rowWidth)
        let bottomBorder = "└" + repeatElement("─", count: rowWidth)
        let horizontalDivider = "├" + repeatElement("┄", count: rowWidth)
        
        super.init { logEntry -> String in
           
            let prefix = "\(logEntry.label)/\(logEntry.level.output(.initial)) - "
            
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
                output(logEntry.date.iso8601String)
                outputHorizontalDivider()
            }
            
            if showThreadInfo {
                let threadId = logEntry.get(.currentThreadId)
                let threadName = logEntry.get(.currentThreadName)
                let dispatchQueueLabel = logEntry.get(.currentDispatchQueueLabel)
                
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
                let backtrace = logEntry.get(.backtrace) ?? []
                let backtraceToLog = backtrace[safe: methodOffset ..< (methodOffset + methodCount)]
                backtraceToLog
                    .map {
                        $0.resolvedFunction(options: .simplified)
                    }
                    .enumerated().forEach { i, line in
                        var s = String(repeating: " ", count: i * 4) + line
                        if i == 0 {
                            s += " - \(logEntry.file.lastPathComponent.deletingPathExtension):\(logEntry.line)"
                        }
                        output(s)
                    }
                outputHorizontalDivider()
            }
            
            logEntry.message.description.enumerateLines { line, _ in
                output(line)
            }
            
            if logEntry.metadata.isEmpty {
                outputBottomBorder()
            } else {
                outputHorizontalDivider()
                
                logEntry.metadata.description.enumerateLines { line, _ in
                    output(line)
                }

                outputBottomBorder()
            }
            
            return message
        }
        
        if showThreadInfo {
            self.register(.currentThreadId)
            self.register(.currentThreadName)
            self.register(.currentDispatchQueueLabel)
        }

        if methodCount > 0 {
            self.register(.backtrace)
        }
    }
}


