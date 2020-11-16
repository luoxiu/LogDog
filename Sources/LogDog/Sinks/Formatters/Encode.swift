import Foundation

public extension LogSink where Output == Void {
    func encode<Encoder: LogEncoder>(encoder: Encoder) -> LogSinks.Concat<Self, LogSinks.Encode<Encoder>> {
        self + LogSinks.Encode(encoder: encoder)
    }
}

public extension LogSinks {
    /// All key-value pairs in the entry's parameters whose key is string and value is codable will be encoded.
    struct Encode<Encoder>: LogSink where Encoder: LogEncoder {
        public typealias Input = Void
        public typealias Output = Encoder.Output

        public let encoder: Encoder

        public init(encoder: Encoder) {
            self.encoder = encoder
        }

        public func sink(_ record: LogRecord<Input>, next: @escaping LogSinkNext<Output>) {
            record.sink(next: next) { record in
                try encoder.encode(LogEntryWrapper(record.entry))
            }
        }
    }
}

private struct LogEntryWrapper: Encodable {
    private let entry: LogEntry

    init(_ entry: LogEntry) {
        self.entry = entry
    }

    private struct Key: CodingKey {
        var intValue: Int? { nil }

        init?(intValue _: Int) { nil }

        let stringValue: String

        init(stringValue: String) {
            self.stringValue = stringValue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)

        try container.encode(entry.label, forKey: Key(stringValue: "label"))
        try container.encode(entry.level.rawValue, forKey: Key(stringValue: "level"))
        try container.encode(String(describing: entry.message), forKey: Key(stringValue: "message"))

        try container.encode(entry.metadata.mapValues(transform), forKey: Key(stringValue: "metadata"))

        try container.encode(entry.source, forKey: Key(stringValue: "source"))
        try container.encode(entry.file, forKey: Key(stringValue: "file"))
        try container.encode(entry.function, forKey: Key(stringValue: "function"))
        try container.encode(entry.line, forKey: Key(stringValue: "line"))

        for (k, v) in entry.parameters.snapshot() {
            guard let key = k.base as? String, let encodable = transform(any: v) else {
                continue
            }
            try container.encode(encodable, forKey: Key(stringValue: key))
        }
    }
}

private func transform(any: Any?) -> AnyEncodable? {
    guard let any = unwrap(any: any) else {
        return AnyEncodable(AnyEncodable?.none)
    }

    switch any {
    case let codable as Encodable:
        return AnyEncodable(codable)
    case let array as [Any?]:
        var elements: [AnyEncodable] = []

        for element in array {
            guard let encodable = transform(any: element) else {
                // not an encodable
                return nil
            }
            elements.append(encodable)
        }

        return AnyEncodable(elements)
    case let dictionary as [String: Any?]:
        var dict: [String: AnyEncodable] = [:]

        for (k, v) in dictionary {
            guard let encodable = transform(any: v) else {
                // not an encodable
                continue
            }
            dict[k] = encodable
        }

        return AnyEncodable(dict)
    default:
        return nil
    }
}

private func transform(_ v: Logger.MetadataValue) -> AnyEncodable {
    switch v {
    case let .string(string):
        return AnyEncodable(string)
    case let .stringConvertible(string):
        return AnyEncodable(string.description)
    case let .dictionary(dict):
        return AnyEncodable(dict.mapValues(transform))
    case let .array(list):
        return AnyEncodable(list.map(transform))
    }
}
