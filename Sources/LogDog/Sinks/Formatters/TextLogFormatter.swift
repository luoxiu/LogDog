import Foundation

public struct TextLogFormatter: LogFormatter {
    public typealias Input = Void
    public typealias Output = String

    private let format: (LogEntry) throws -> String

    public init(format: @escaping (LogEntry) throws -> String) {
        self.format = format
    }

    public static let `default` = TextLogFormatter { entry in
        let level = entry.level.initial

        let time = LogHelper.currentTime
        let ms = CFAbsoluteTimeGetCurrent()

        let filename = entry.file

        var output = "\(time) \(entry.label) \(level)/\(filename):\(entry.line) \(entry.message)"

        if entry.metadata.isEmpty {
            output += "\n"
        } else {
            let metadata = entry.metadata
                .map {
                    "\($0)=\($1)"
                }
                .joined(separator: ", ")

            output += " \(metadata)\n"
        }

        return output
    }

    public func format(_ record: LogRecord<Void>) throws -> String? {
        try format(record.entry)
    }
}
