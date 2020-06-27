public struct TextLogFormatter: LogFormatter {
    
    public typealias I = Void
    public typealias O = String
    
    public static let singleLine = TextLogFormatter { rawLog in
        "\(rawLog.level.output(.emoji3)) \(rawLog.date.timeString) - \(rawLog.label) -> \(rawLog.file.asPath.filenameWithoutExtension):\(rawLog.line) - \(rawLog.function) -> \(rawLog.message.description)\(rawLog.metadata.isEmpty ? "" : " 📦 \(rawLog.metadata)")"
    }
    
    private let _format: (RawLog) -> String
    
    public init(_ format: @escaping (RawLog) -> String) {
        _format = format
    }
    
    public func format(_ log: Log<Void>) -> Log<String> {
        let rawLog = log.rawLog
        let formatted = _format(rawLog)
        return Log(rawLog, formatted)
    }
}

