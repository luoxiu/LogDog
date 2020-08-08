import Foundation

public struct TextLogProcessor: LogProcessor {
    
    public typealias Input = Void
    public typealias Output = String
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public let format: (LogEntry) -> String
    
    public init(format: @escaping (LogEntry) -> String) {
        self.format = format
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Void>) throws -> ProcessedLogEntry<String> {
        logEntry.map {
            format(logEntry.rawLogEntry)
        }
    }
}

extension TextLogProcessor {
    
    public enum FormatStyle {
        case plain
        case emoji
    }
    
    public static func preferredFormat(_ style: FormatStyle) -> TextLogProcessor {
        switch style {
        case .plain:    return .plain
        case .emoji:    return .emoji
        }
    }
    
    private static let plain = TextLogProcessor { logEntry in
        let time = logEntry.date.datetimeString
        let level = logEntry.level.output(.initial).capitalized
        let label = logEntry.label
        
        let message = logEntry.message.description
        let metadata = logEntry.metadata.isEmpty ? "" : "  \(logEntry.metadata)"

        return "\(time) \(level)/\(label): \(message)\(metadata)"
    }

    private static let emoji = TextLogProcessor { logEntry in
        let level = logEntry.level.output(.emoji)
        let time = logEntry.date.timeString
        let label = logEntry.label
        let filename = logEntry.file.ns.lastPathComponent
        let line = logEntry.line
        let function = logEntry.function
        let message = logEntry.message.description
        let metadata = logEntry.metadata.isEmpty ? "" : " 📦 \(logEntry.metadata)"

        return "\(label):\(level) \(time) \(filename):\(line) \(function) -> \(message)\(metadata)"
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
    
    private static let datetimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    var datetimeString: String {
        Self.datetimeFormatter.string(from: self)
    }
}
