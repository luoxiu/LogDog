import Foundation

public struct LogStringify {
    public typealias Stringify<T> = (T) -> String

    private var exact: [AnyHashable: (Any) -> String?]
    private var fuzzy: [AnyHashable: (Any) -> String?]

    public init() {
        exact = [:]
        fuzzy = [:]
    }

    public mutating func use<T>(_ stringify: @escaping Stringify<T>) {
        exact[ObjectIdentifier(T.self)] = { any -> String? in
            if let t = any as? T {
                return stringify(t)
            }
            return nil
        }
    }

    public mutating func set<T>(_ stringify: @escaping Stringify<T>) {
        fuzzy[ObjectIdentifier(T.self)] = { any -> String? in
            if let t = any as? T {
                return stringify(t)
            }
            return nil
        }
    }

    public mutating func reset<T>(_ type: T.Type) {
        exact[ObjectIdentifier(type)] = nil
        fuzzy[ObjectIdentifier(type)] = nil
    }

    public mutating func resetAll() {
        exact = [:]
        fuzzy = [:]
    }

    public func stringify(_ any: Any) -> String {
        let key = type(of: any)

        if let stringify = exact[ObjectIdentifier(key)], let string = stringify(any) {
            return string
        }

        for stringify in fuzzy.values {
            if let string = stringify(any) {
                return string
            }
        }

        return String(describing: any)
    }

    public static func stringify(_ any: Any) -> String {
        `default`.stringify(any)
    }
}

public extension LogStringify {
    static var `default`: LogStringify = {
        var stringify = LogStringify()
        stringify.use(data)
        return stringify
    }()

    static var data: Stringify<Data> = {
        LogHelper.stringify($0)
    }
}
