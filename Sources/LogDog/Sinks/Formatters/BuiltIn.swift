import Foundation

public extension LogSinks {
    struct BuiltIn: LogSink {
        public typealias Input = Void
        public typealias Output = String

        public enum Style {
            /// Short
            ///
            ///     E: bad response
            ///     C: can not connect to db
            case short
            /// Medium
            ///
            ///     17:40:56.850 E/App main.swift.39: bad response url=/me, status_code=404
            ///     17:40:56.850 C/App main.swift.41: can not connect to db
            case medium
            /// Long
            ///
            ///     ╔════════════════════════════════════════════════════════════════════════════════
            ///     ║ 2020-11-16 18:46:31.157  App  ERROR     (main.swift:39  run(_:))
            ///     ╟────────────────────────────────────────────────────────────────────────────────
            ///     ║ bad response
            ///     ╟────────────────────────────────────────────────────────────────────────────────
            ///     ║ url=/me
            ///     ║ status_code=404
            ///     ╚════════════════════════════════════════════════════════════════════════════════
            case long
        }

        public let style: Style

        private let sink: AnyLogSink<Void, String>

        private init(style: Style) {
            self.style = style

            switch style {
            case .short:
                sink = LogSinks.BuiltIn.underlyingShort
            case .medium:
                sink = LogSinks.BuiltIn.underlyingMedium
            case .long:
                sink = LogSinks.BuiltIn.underlyingLong
            }
        }

        public func beforeSink(_ entry: inout LogEntry) {
            sink.beforeSink(&entry)
        }

        public func sink(_ record: LogRecord<Void>, next: @escaping LogSinkNext<String>) {
            sink.sink(record, next: next)
        }
    }
}

public extension LogSinks.BuiltIn {
    static let short = LogSinks.BuiltIn(style: .short)

    static let medium = LogSinks.BuiltIn(style: .medium)

    static let long = LogSinks.BuiltIn(style: .long)
}

// MARK: Short

extension LogSinks.BuiltIn {
    private static let underlyingShort: AnyLogSink<Void, String> = .init { record, next in
        record.sink(next: next) { (record) -> String? in
            let level = record.entry.level.initial
            return "\(level): \(record.entry.message)"
        }
    }
}

// MARK: Medium

extension LogSinks.BuiltIn {
    private struct Medium: LogParameterKey {
        typealias Value = Medium

        let date = Date()
    }

    private static let underlyingMedium: AnyLogSink<Void, String> = .init {
        $0.parameters[Medium.self] = .init()
    } sink: { record, next in
        record.sink(next: next) { (record) -> String? in
            guard let medium = record.entry.parameters[Medium.self] else {
                return nil
            }

            let time = LogHelper.format(medium.date, using: "HH:mm:ss.SSS")
            let level = record.entry.level.initial
            let filename = LogHelper.basename(of: record.entry.file)

            var output = "\(time) \(level)/\(record.entry.label) \(filename).\(record.entry.line): \(record.entry.message)"

            if !record.entry.metadata.isEmpty {
                let metadata = record.entry.metadata
                    .map {
                        "\($0)=\($1)"
                    }
                    .joined(separator: ", ")

                output += " \(metadata)"
            }

            return output
        }
    }
}

// MARK: Long

extension LogSinks.BuiltIn {
    private struct Long: LogParameterKey {
        typealias Value = Long

        let date = Date()
    }

    private static let width = 80
    private static let borderTop = "╔" + repeatElement("═", count: width)
    private static let borderBottom = "╚" + repeatElement("═", count: width)
    private static let separator = "╟" + repeatElement("─", count: width)

    private static func writeTop(to string: inout String) {
        string += "\(borderTop)\n"
    }

    private static func writeBottom(to string: inout String) {
        string += "\(borderBottom)"
    }

    private static func writeSeparator(to string: inout String) {
        string += "\(separator)\n"
    }

    private static func write(line: String, to string: inout String) {
        string += "║ \(line)\n"
    }

    static let underlyingLong: AnyLogSink<Void, String> = .init {
        $0.parameters[Long.self] = .init()
    } sink: { record, next in
        record.sink(next: next) { (record) -> String? in
            guard let long = record.entry.parameters[Long.self] else {
                return nil
            }

            let time = LogHelper.format(long.date, using: "yyyy-MM-dd HH:mm:ss.SSS")
            let level = record.entry.level.uppercased.padding(toLength: 8, withPad: " ", startingAt: 0)
            let filename = LogHelper.basename(of: record.entry.file)

            var sections: [[String]] = []

            sections.append([
                "\(time)  \(record.entry.label)  \(level)  (\(filename):\(record.entry.line)  \(record.entry.function))",
            ])

            sections.append(["\(record.entry.message)"])

            if !record.entry.metadata.isEmpty {
                let metadata = record.entry.metadata
                    .map {
                        "\($0)=\($1)"
                    }
                sections.append(metadata)
            }

            var output = ""

            writeTop(to: &output)

            for (index, section) in sections.enumerated() {
                if index != 0 {
                    writeSeparator(to: &output)
                }
                for line in section {
                    write(line: line, to: &output)
                }
            }

            writeBottom(to: &output)

            return output
        }
    }
}
