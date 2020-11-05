public protocol LogParameterKey {
    associatedtype Value

    static var key: AnyHashable { get }
}

public extension LogParameterKey {
    static var key: AnyHashable {
        ObjectIdentifier(self)
    }
}

public protocol LogParameterCodingKey: LogParameterKey {
    associatedtype CodingKey: Hashable & Encodable

    static var codingKey: CodingKey {
        get
    }
}

public extension LogParameterCodingKey {
    static var key: AnyHashable {
        codingKey
    }

    static var codingKey: String {
        let name = String(describing: self)
        return name.prefix(1).lowercased() + name.dropFirst()
    }
}

public struct LogParameters {
    private var dict: [AnyHashable: Any]

    public init() {
        dict = [:]
    }

    public subscript<Key>(_ key: Key.Type) -> Key.Value?
        where Key: LogParameterKey
    {
        get {
            dict[key.key] as? Key.Value
        }
        set {
            dict[key.key] = newValue
        }
    }

    public subscript(_ key: AnyHashable) -> Any? {
        get {
            dict[key]
        }
        set {
            dict[key] = newValue
        }
    }

    func snapshot() -> [AnyHashable: Any] {
        dict
    }
}
