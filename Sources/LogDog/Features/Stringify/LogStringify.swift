import Foundation

/// Use LogStringify to customize the value of `.any(x)`.
///
///     stringify.set { c: UIColor in
///         "UIColor: \(c.hex)"
///     }
///
///     .any(color)         // UIColor: 0xffffff
public struct LogStringify {
    public typealias Stringify<T> = (T) -> String

    private var exact: [AnyHashable: (Any) -> String?]
    private var fuzzy: [(Any) -> String?]

    public init() {
        exact = [:]
        fuzzy = []
    }

    /// `set` exactly matches the type.
    ///
    ///     class A {
    ///         var num = 0
    ///         var description: String {
    ///             "\(num)"
    ///         }
    ///     }
    ///     class B: A { }
    ///
    ///     .any(a)         // "0"
    ///     .any(b)         // "0"
    ///
    ///     stringify.set { a: A in
    ///         "type(of:a): \(a.num)"
    ///     }
    ///
    ///     .any(a)         // "A: 0"
    ///     .any(b)         // "0"
    public mutating func set<T>(_ stringify: @escaping Stringify<T>) {
        exact[ObjectIdentifier(T.self)] = { any -> String? in
            if let t = any as? T {
                return stringify(t)
            }
            return nil
        }
    }

    /// `use` fuzzyly matches the type.
    ///
    ///     class A {
    ///         var num = 0
    ///         var description: String {
    ///             "\(num)"
    ///         }
    ///     }
    ///     class B: A { }
    ///
    ///     .any(a)         // "0"
    ///     .any(b)         // "0"
    ///
    ///     stringify.use { a: A in
    ///         "type(of:a): \(a.num)"
    ///     }
    ///
    ///     .any(a)         // "A: 0"
    ///     .any(b)         // "B: 0"
    public mutating func use<T>(_ stringify: @escaping Stringify<T>) {
        let body: (Any) -> String? = { any -> String? in
            if let t = any as? T {
                return stringify(t)
            }
            return nil
        }

        fuzzy.append(body)
    }

    /// reset the stringify.
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

        for stringify in fuzzy {
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
