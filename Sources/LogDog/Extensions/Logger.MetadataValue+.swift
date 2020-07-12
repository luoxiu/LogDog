import Logging

extension Logger.MetadataValue {
    public static func any(_ any: Any) -> Logger.MetadataValue {
        .string("\(any)")
    }
}

extension Logger.MetadataValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case .stringConvertible(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string.description)
        case .dictionary(let metadata):
            try metadata.encode(to: encoder)
        case .array(let values):
            try values.encode(to: encoder)
        }
    }
}

extension Logger.MetadataValue: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = .string(value)
        } catch {
            do {
                let metadata = try Logger.Metadata(from: decoder)
                self = .dictionary(metadata)
            } catch {
                let values = try [Logger.MetadataValue](from: decoder)
                self = .array(values)
            }
        }
    }
}

