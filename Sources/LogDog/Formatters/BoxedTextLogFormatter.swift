/// inspired by https://github.com/orhanobut/logger
public struct BoxedTextLogFormatter: LogFormatter {
    
    public typealias I = Void
    public typealias O = String
    
    private let formatter: TextLogFormatter
    
    private static let topBorder = "┌──────────────────────────────────────────────────────────────────────"
    private static let bottomBorder = "└──────────────────────────────────────────────────────────────────────"
    private static let horizontalDivider = "├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"
    
    public let showDate: Bool
    public let showThreadInfo: Bool
    public let methodCount: Int
    public let methodOffset: Int
    
    public init(
        showDate: Bool = false,
        showThreadInfo: Bool = false,
        methodCount: Int = 0,
        methodOffset: Int = 4
    ) {
        self.showDate = showDate
        self.showThreadInfo = showThreadInfo
        self.methodCount = methodCount
        self.methodOffset = methodOffset
        
        formatter = TextLogFormatter { rawLog -> String in
            let prefix = "\(rawLog.label)/\(rawLog.level.output(.initial)) - "
            
            var message = ""
            
            func output(_ line: String) {
                message += prefix
                message += "| "
                message += line
                message += "\n"
            }
            
            func outputHorizontalDivider() {
                message += prefix
                message += Self.horizontalDivider
                message += "\n"
            }
            
            func outputTopBorder() {
                message += prefix
                message += Self.topBorder
                message += "\n"
            }
            
            func outputBottomBorder() {
                message += prefix
                message += Self.bottomBorder
            }
            
            outputTopBorder()
            
            if showDate {
                output(rawLog.date.isoString)
                outputHorizontalDivider()
            }
            
            if showThreadInfo {
                var threadInfo = ""
                if let threadName = rawLog.threadName, threadName.count > 0 {
                    threadInfo = "Thread \(threadName)"
                } else if let label = rawLog.dispatchQueueLabel, label.count > 0 {
                    threadInfo = label
                } else {
                    threadInfo = "Thread \(rawLog.threadId)"
                }
                
                output(threadInfo)
                outputHorizontalDivider()
            }
            
            if methodCount > 0 { // backtrace
                let backtrace = rawLog.backtrace[safe: methodOffset ..< (methodOffset + methodCount)]
                backtrace
                    .map {
                        $0.resolvedFunction(options: .simplified)
                    }
                    .enumerated().forEach { i, line in
                        var s = String(repeating: " ", count: i * 4) + line
                        if i == 0 {
                            s += " - \(rawLog.file.asPath.filename):\(rawLog.line)"
                        }
                        output(s)
                    }
                outputHorizontalDivider()
            }
            
            rawLog.message.description.enumerateLines { line, _ in
                output(line)
            }
            
            if rawLog.metadata.isEmpty {
                outputBottomBorder()
            } else {
                outputHorizontalDivider()
                
                rawLog.metadata.description.enumerateLines { line, _ in
                    output(line)
                }

                outputBottomBorder()
            }
            
            return message
        }
    }
    
    public func format(_ log: Log<Void>) -> Log<String> {
        formatter.format(log)
    }
}


