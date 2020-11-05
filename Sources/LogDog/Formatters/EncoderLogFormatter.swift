import Foundation

public struct EncoderLogFormatter<Output>: LogFormatter {
    
    public typealias Input = Void
    
    let encoder: AnyLogEncoder<Output>
    
    public init<Encoder>(_ encoder: Encoder) where Encoder: LogEncoder, Encoder.Output == Output {
        self.encoder = .init(encoder)
    }
    
    public func format(_ record: LogRecord<Void>) throws -> Output? {
        try encoder.encode(LogEntryWrapper(record.entry))
    }
}

private struct LogEntryWrapper: Encodable {
    
    private let entry: LogEntry
    
    init(_ entry: LogEntry) {
        self.entry = entry
    }
    
    private struct Key: CodingKey {
        var intValue: Int? { nil }
        
        init?(intValue: Int) { nil }
        
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
            guard let key = k as? String, let encodable = transform(any: v) else {
                continue
            }
            try container.encode(encodable, forKey: Key(stringValue: key))
        }
    }
}

private func transform(any: Any?) -> AnyEncodable? {
    guard let any = any else {
        return AnyEncodable(Optional<AnyEncodable>.none)
    }
    
    switch any {
    case let codable as Encodable:
        return AnyEncodable(codable)
    case let array as Array<Any?>:
        var elements: [AnyEncodable] = []
        
        for element in array {
            guard let encodable = transform(any: element) else {
                return nil
            }
            elements.append(encodable)
        }
        
        return AnyEncodable(elements)
    case let dictionary as Dictionary<String, Any?>:
        var dict: [String: AnyEncodable] = [:]
        
        for (k, v) in dictionary {
            guard let encodable = transform(any: v) else {
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
    case .string(let string):
        return AnyEncodable(string)
    case .stringConvertible(let string):
        return AnyEncodable(string.description)
    case .dictionary(let dict):
        return AnyEncodable(dict.mapValues(transform))
    case .array(let list):
        return AnyEncodable(list.map(transform))
    }
}
