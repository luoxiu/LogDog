import Foundation

public protocol LogEncoder {
    associatedtype Output

    func encode<T>(_ value: T) throws -> Self.Output where T: Encodable
}

extension JSONEncoder: LogEncoder {}

extension PropertyListEncoder: LogEncoder {}
