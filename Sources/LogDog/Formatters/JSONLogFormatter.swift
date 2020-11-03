import Foundation

public struct JSONLogFormatter: LogFormatter {
    
    public typealias Input = Void
    public typealias Output = Data
    
    public let jsonEncoder: JSONEncoder
    
    public private(set) var hooks: [LogHook]?
    
    private struct ExtrasKey: LogParameterKey {
        typealias Value = [String: AnyJSONEncodable]
    }
    
    public init(jsonEncoder: JSONEncoder = JSONEncoder(),
                withExtras: ((inout [String: AnyJSONEncodable]) -> Void)? = nil) {
        self.jsonEncoder = jsonEncoder
        
        if let withExtras = withExtras {
            var hooks: [LogHook] = []
            hooks.use { entry in
                if entry.parameters[ExtrasKey.self] == nil {
                    entry.parameters[ExtrasKey.self] = [:]
                }
                withExtras(&entry.parameters[ExtrasKey.self]!)
            }
            self.hooks = hooks
        }
    }
    
    public func format(_ record: LogRecord<Void>) throws -> Data? {
        var json: [String: AnyJSONEncodable] = [:]
        json["label"] = AnyJSONEncodable(record.entry.label)
        json["level"] = AnyJSONEncodable(record.entry.level.rawValue)
        json["message"] = AnyJSONEncodable("\(record.entry.message)")
        
        func transform(_ v: Logger.MetadataValue) -> AnyJSONEncodable {
            switch v {
            case .string(let string):
                return AnyJSONEncodable(string)
            case .stringConvertible(let string):
                return AnyJSONEncodable(string.description)
            case .dictionary(let dict):
                return AnyJSONEncodable(dict.mapValues(transform))
            case .array(let list):
                return AnyJSONEncodable(list.map(transform))
            }
        }
        
        json["metadata"] = .init(record.entry.metadata.mapValues(transform))
        json["source"] = .init(record.entry.source)
        json["file"] = .init(record.entry.file)
        json["function"] = .init(record.entry.function)
        json["line"] = .init(record.entry.line)
        
        if let extras = record.entry.parameters[ExtrasKey.self] {
            json.merge(extras, uniquingKeysWith: { _, b in b })
        }
        
        return try jsonEncoder.encode(json)
    }
}

// MARK: AnyJSONEncodable
public struct AnyJSONEncodable: Encodable {

    private let encodable: AbstractJSONEncodable
    
    public init<T>(_ encodable: T) where T: Encodable {
        self.encodable = CodableBox(encodable)
    }

    public func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}

private class AbstractJSONEncodable: Encodable {
    
    func encode(to encoder: Encoder) throws {
        fatalError()
    }
}

private final class CodableBox<T>: AbstractJSONEncodable where T: Encodable {
    
    private var encodable: T
    
    init(_ encodable: T) {
        self.encodable = encodable
    }
    
    override func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}

extension AnyJSONEncodable: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension AnyJSONEncodable: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension AnyJSONEncodable: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension AnyJSONEncodable: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension AnyJSONEncodable: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: AnyJSONEncodable...) {
        self.init(elements)
    }
}

extension AnyJSONEncodable: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, AnyJSONEncodable)...) {
        self.init([String: AnyJSONEncodable](elements) { a, _ in a })
    }
}
