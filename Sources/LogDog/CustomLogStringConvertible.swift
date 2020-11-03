extension Logger.MetadataValue {
    public static func any(_ any: Any) -> Logger.MetadataValue {
        if let any = any as? CustomLogStringConvertible {
            return .string(any.logDescription)
        }
        return .string(String(describing: any))
    }
}

public protocol CustomLogStringConvertible {
    var logDescription: String { get }
}
