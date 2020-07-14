import Foundation

public struct TextLogProcessor: LogProcessor {
    
    public typealias Input = Void
    public typealias Output = String
    
    public var contextCaptures: [String : () -> LossLessMetadataValueConvertible?] = [:]
    
    public let transform: (LogEntry) -> String
    
    public init(_ transform: @escaping (LogEntry) -> String) {
        self.transform = transform
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Void>) throws -> ProcessedLogEntry<String> {
        logEntry.map {
            self.transform(logEntry.rawLogEntry)
        }
    }
}

extension TextLogProcessor {
    
    public static let singleLine = TextLogProcessor { logEntry in
        let level = logEntry.level.output(.emoji3)
        let time = logEntry.date.timeString
        let label = logEntry.label
        let filename = logEntry.file.lastPathComponent.deletingPathExtension
        let line = logEntry.line
        let function = logEntry.function
        let message = logEntry.message.description
        let metadata = logEntry.metadata.isEmpty ? "" : " 📦 \(logEntry.metadata)"

        return "\(label):\(level) \(time) -> \(filename):\(line) - \(function) -> \(message)\(metadata)"
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
