extension Logger.MetadataValue {
    public static func x(_ x: Any) -> Logger.MetadataValue {
        .string(String(describing: x))
    }
    
    public static func any(_ any: Any) -> Logger.MetadataValue {
        .string(String(describing: any))
    }
}

// MARK: - Codable
extension Logger.MetadataValue: Codable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case .stringConvertible(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string.description)
        case .dictionary(let dict):
            try dict.encode(to: encoder)
        case .array(let list):
            try list.encode(to: encoder)
        }
    }

    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            self = .string(string)
        } catch {
            do {
                let dict = try Logger.Metadata(from: decoder)
                self = .dictionary(dict)
            } catch {
                let list = try [Logger.MetadataValue](from: decoder)
                self = .array(list)
            }
        }
    }
}

