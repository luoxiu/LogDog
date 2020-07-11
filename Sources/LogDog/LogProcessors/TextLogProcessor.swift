open class TextLogProcessor: LogProcessor<Void, String> {
    
    public static let singleLine = TextLogProcessor { rawLog in
        "\(rawLog.level.output(.emoji3)) \(rawLog.date.timeString) - \(rawLog.label) -> \(rawLog.file.asPath.filenameWithoutExtension):\(rawLog.line) - \(rawLog.function) -> \(rawLog.message.description)\(rawLog.metadata.isEmpty ? "" : " 📦 \(rawLog.metadata)")"
    }
    
    public init(_ format: @escaping (LogEntry) -> String) {
        super.init {
            let rawLog = $0.raw
            let formatted = format(rawLog)
            return ProcessedLogEntry(rawLog, formatted)
        }
    }
}

