public protocol LogParameterKey {
    associatedtype Value
}

public struct LogParameters {
    
    private var storage: [ObjectIdentifier: Any]
    
    public init() {
        self.storage = [:]
    }
    
    public subscript<Key>(_ key: Key.Type) -> Key.Value?
        where Key: LogParameterKey
    {
        get {
            storage[ObjectIdentifier(key.self)] as? Key.Value
        }
        set {
            storage[ObjectIdentifier(key.self)] = newValue
        }
    }
}
