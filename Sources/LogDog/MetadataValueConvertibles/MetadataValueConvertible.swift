import Logging

public protocol MetadataValueConvertible {

    var metadataValue: Logger.MetadataValue { get }
    
    init?(_ metadataValue: Logger.MetadataValue)
}

extension Logger.MetadataValue {
    
    public static func any(_ any: Any) -> Logger.MetadataValue {
        switch any {
        case let v as MetadataValueConvertible:
            return v.metadataValue
        default:
            return "\(any)"
        }
    }
}

extension MetadataValueConvertible where Self: LosslessStringConvertible {
    public var metadataValue: Logger.MetadataValue {
        return .stringConvertible(self)
    }
    
    public init?(_ metadataValue: Logger.MetadataValue) {
        switch metadataValue {
        case .stringConvertible(let s):
            self.init(s.description)
        default:
            return nil
        }
    }
}

extension Bool: MetadataValueConvertible { }

extension Float: MetadataValueConvertible { }
extension Double: MetadataValueConvertible { }

extension String: MetadataValueConvertible { }

extension Int: MetadataValueConvertible { }
extension Int8: MetadataValueConvertible { }
extension Int16: MetadataValueConvertible { }
extension Int32: MetadataValueConvertible { }
extension Int64: MetadataValueConvertible { }

extension UInt: MetadataValueConvertible { }
extension UInt8: MetadataValueConvertible { }
extension UInt16: MetadataValueConvertible { }
extension UInt32: MetadataValueConvertible { }
extension UInt64: MetadataValueConvertible { }

extension Array: MetadataValueConvertible where Element: MetadataValueConvertible {
    public var metadataValue: Logger.MetadataValue {
        .array(map { $0.metadataValue })
    }
    
    public init?(_ metadataValue: Logger.MetadataValue) {
        switch metadataValue {
        case .array(let values):
            var elements: [Element] = []
            elements.reserveCapacity(values.count)
            
            for value in values {
                guard let element = Element(value) else {
                    return nil
                }
                elements.append(element)
            }
            
            self = elements
        default:
            return nil
        }
    }
}

extension Dictionary: MetadataValueConvertible where Key == String, Value: MetadataValueConvertible {
    public var metadataValue: Logger.MetadataValue {
        .dictionary(mapValues { $0.metadataValue })
    }
    
    public init?(_ metadataValue: Logger.MetadataValue) {
        switch metadataValue {
        case .dictionary(let metadata):
            var dict: [Key: Value] = [:]
            
            for (k, v) in metadata {
                guard let value = Value(v) else {
                    return nil
                }
                dict[k] = value
            }
            
            self = dict
        default:
            return nil
        }
    }
}
