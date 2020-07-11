open class TextLogFormatter: LogFormatter<Void, String> {
    
    public static let singleLine = TextLogFormatter { rawLog in
        "\(rawLog.level.output(.emoji3)) \(rawLog.date.timeString) - \(rawLog.label) -> \(rawLog.file.asPath.filenameWithoutExtension):\(rawLog.line) - \(rawLog.function) -> \(rawLog.message.description)\(rawLog.metadata.isEmpty ? "" : " 📦 \(rawLog.metadata)")"
    }
    
    public init(_ format: @escaping (LogEntry) -> String) {
        super.init {
            let rawLog = $0.origin
            let formatted = format(rawLog)
            return FormattedLogEntry(rawLog, formatted)
        }
    }
}

