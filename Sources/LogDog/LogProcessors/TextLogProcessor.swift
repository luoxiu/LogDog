import Foundation

open class TextLogProcessor: LogProcessor<Void, String> {
    
    public init(_ format: @escaping (LogEntry) -> String) {
        super.init {
            let rawLog = $0.raw
            let formatted = format(rawLog)
            return ProcessedLogEntry(rawLog, formatted)
        }
    }
}

extension TextLogProcessor {
    
    public static let singleLine = TextLogProcessor {
        let level = $0.level.output(.emoji3)
        let time = $0.date.timeString
        let label = $0.label
        let filename = $0.file.lastPathComponent.deletingPathExtension
        let line = $0.line
        let function = $0.function
        let message = $0.message.description
        let metadata = $0.metadata.isEmpty ? "" : " 📦 \($0.metadata)"
        
        return "\(level) \(time) - \(label) -> \(filename):\(line) - \(function) -> \(message)\(metadata)"
    }
}

private extension Date {
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    var timeString: String {
        Self.timeFormatter.string(from: self)
    }
}
