extension LogHandler {
    public subscript(metadataKey metadataKey: String) -> Logger.MetadataValue? {
        get {
            metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
        }
    }
}

extension Logger.MetadataValue {
    public static func any(_ any: Any) -> Logger.MetadataValue {
        return .string(String(describing: any))
    }
}

/// performance
extension Logger.Level {
    private static let uppercased = [
        "TRACE", "DEBUG", "INFO", "NOTICE", "WARNING", "ERROR", "CRITICAL"
    ]
    
    private static let initial = [
        "T", "D", "I", "N", "W", "E", "C"
    ]
    
    private var intValue: Int {
        switch self {
        case .trace:    return 0
        case .debug:    return 1
        case .info:     return 2
        case .notice:   return 3
        case .warning:  return 4
        case .error:    return 5
        case .critical: return 6
        }
    }
    
    public var uppercased: String {
        Self.uppercased[intValue]
    }
    
    public var initial: String {
        Self.initial[intValue]
    }
}
