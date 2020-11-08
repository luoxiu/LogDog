import Foundation

public struct LogStringify {
    public typealias Stringify<T> = (T) -> String

    private var exact: [AnyHashable: (Any) -> String?]
    private var fuzzy: [(ObjectIdentifier, (Any) -> String?)]

    public init() {
        exact = [:]
        fuzzy = []
    }

    public mutating func set<T>(_ stringify: @escaping Stringify<T>) {
        exact[ObjectIdentifier(T.self)] = { any -> String? in
            if let t = any as? T {
                return stringify(t)
            }
            return nil
        }
    }

    public mutating func use<T>(_ stringify: @escaping Stringify<T>) {
        let body: (Any) -> String? = { any -> String? in
            if let t = any as? T {
                return stringify(t)
            }
            return nil
        }

        fuzzy.append((ObjectIdentifier(T.self), body))
    }

    public mutating func useFirst<T>(_ stringify: @escaping Stringify<T>) {
        let body: (Any) -> String? = { any -> String? in
            if let t = any as? T {
                return stringify(t)
            }
            return nil
        }

        fuzzy.insert((ObjectIdentifier(T.self), body), at: 0)
    }

    public mutating func clear() {
        exact = [:]
        fuzzy = []
    }

    /// NSValue() / NSNumber() will crash.
    public func stringify(_ any: Any) -> String {
        let key = type(of: any)
        if let stringify = exact[ObjectIdentifier(key)], let string = stringify(any) {
            return string
        }

        for (_, stringify) in fuzzy {
            if let string = stringify(any) {
                return string
            }
        }

        return String(describing: any)
    }
}

// MARK: builtins

public extension LogStringify {
    static var `default`: LogStringify = {
        var stringify = LogStringify()
        stringify.set(data)
        return stringify
    }()

    static var data: Stringify<Data> = {
        LogHelper.stringify($0)
    }
}


