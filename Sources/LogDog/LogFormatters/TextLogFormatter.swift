public struct TextLogFormatter: LogFormatter {
    
    public typealias I = Void
    public typealias O = String
    
    public static let singleLine = TextLogFormatter { rawLog in
        "\(rawLog.level.output(.emoji3)) \(rawLog.date.timeString) - \(rawLog.label) -> \(rawLog.file.asPath.filenameWithoutExtension):\(rawLog.line) - \(rawLog.function) -> \(rawLog.message.description)\(rawLog.metadata.isEmpty ? "" : " 📦 \(rawLog.metadata)")"
    }
    
    private let _format: (LogEntry) -> String
    
    public init(_ format: @escaping (LogEntry) -> String) {
        _format = format
    }
    
    public func format(_ log: FormattedLogEntry<Void>) -> FormattedLogEntry<String> {
        let rawLog = log.rawLog
        let formatted = _format(rawLog)
        return FormattedLogEntry(rawLog, formatted)
    }
}

