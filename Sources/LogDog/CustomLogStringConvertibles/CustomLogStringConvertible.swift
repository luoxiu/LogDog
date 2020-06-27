import Foundation
import Logging

public protocol CustomLogStringConvertible {
    
    var logDescription: String { get }
}

extension Logger.MetadataValue {
    
    public static func any(_ any: Any) -> Logger.MetadataValue {
        switch any {
        case let a as CustomLogStringConvertible:
            return .string(a.logDescription)
        case let a as CustomStringConvertible:
            return .stringConvertible(a)
        default:
            return "\(any)"
        }
    }
}
