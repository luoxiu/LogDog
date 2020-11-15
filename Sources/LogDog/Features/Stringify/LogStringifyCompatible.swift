/// Let `x` conform to `LogStringifyCompatible` to customize the value of `.any(x)`.
public protocol LogStringifyCompatible {
    var stringified: String { get }
}
