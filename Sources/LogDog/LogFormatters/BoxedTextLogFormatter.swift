///// inspired by https://github.com/orhanobut/logger
//open class BoxedTextLogFormatter: TextLogFormatter {
//    
//    private static let topBorder = "┌──────────────────────────────────────────────────────────────────────"
//    private static let bottomBorder = "└──────────────────────────────────────────────────────────────────────"
//    private static let horizontalDivider = "├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
//    
//    public let showDate: Bool
//    public let showThreadInfo: Bool
//    public let methodCount: Int
//    public let methodOffset: Int
//    
//    enum ContextKey: String {
//        case threadId
//        case threadName
//        case dispatchQueueLabel
//    }
//    
//    public init(
//        showDate: Bool = false,
//        showThreadInfo: Bool = false,
//        methodCount: Int = 0,
//        methodOffset: Int = 4
//    ) {
//        self.showDate = showDate
//        self.showThreadInfo = showThreadInfo
//        self.methodCount = methodCount
//        self.methodOffset = methodOffset
//        
//        self.dynamicContext[ContextKey.threadId.rawValue] = {
//            .string(ContextUtil.currentThreadId)
//        }
//        self.dynamicContext[ContextKey.threadName.rawValue] = {
//            ContextUtil.currentThreadName
//        }
//        self.dynamicContext[ContextKey.dispatchQueueLabel.rawValue] = {
//            ContextUtil.currentDispatchQueueLabel
//        }
//        
//        
//        super.init { logEntry -> String in
//            
//            let threadId = logEntry.context[ContextKey.threadId.rawValue] as? String
//            let threadName = logEntry.context[ContextKey.threadName.rawValue] as? String
//            let dispatchQueueLabel = logEntry.context[ContextKey.dispatchQueueLabel.rawValue] as? String
//            
//            let prefix = "\(logEntry.label)/\(logEntry.level.output(.initial)) - "
//            
//            var message = ""
//            
//            func output(_ line: String) {
//                message += prefix
//                message += "| "
//                message += line
//                message += "\n"
//            }
//            
//            func outputHorizontalDivider() {
//                message += prefix
//                message += Self.horizontalDivider
//                message += "\n"
//            }
//            
//            func outputTopBorder() {
//                message += prefix
//                message += Self.topBorder
//                message += "\n"
//            }
//            
//            func outputBottomBorder() {
//                message += prefix
//                message += Self.bottomBorder
//            }
//            
//            outputTopBorder()
//            
//            if showDate {
//                output(logEntry.date.isoString)
//                outputHorizontalDivider()
//            }
//            
//            if showThreadInfo {
//                var threadInfo = ""
//                if let threadName = threadName, threadName.count > 0 {
//                    threadInfo = "Thread \(threadName)"
//                } else if let label = dispatchQueueLabel, label.count > 0 {
//                    threadInfo = label
//                } else {
//                    threadInfo = "Thread \(threadId as Any)"
//                }
//                
//                output(threadInfo)
//                outputHorizontalDivider()
//            }
//            
//            if methodCount > 0 { // backtrace
//                let backtrace = logEntry.backtrace[safe: methodOffset ..< (methodOffset + methodCount)]
//                backtrace
//                    .map {
//                        $0.resolvedFunction(options: .simplified)
//                    }
//                    .enumerated().forEach { i, line in
//                        var s = String(repeating: " ", count: i * 4) + line
//                        if i == 0 {
//                            s += " - \(logEntry.file.asPath.filename):\(logEntry.line)"
//                        }
//                        output(s)
//                    }
//                outputHorizontalDivider()
//            }
//            
//            logEntry.message.description.enumerateLines { line, _ in
//                output(line)
//            }
//            
//            if logEntry.metadata.isEmpty {
//                outputBottomBorder()
//            } else {
//                outputHorizontalDivider()
//                
//                logEntry.metadata.description.enumerateLines { line, _ in
//                    output(line)
//                }
//
//                outputBottomBorder()
//            }
//            
//            return message
//        }
//    }
//}
//
//
