import Foundation

public protocol LossLessMetadataValueConvertible {

    var metadataValue: Logger.MetadataValue { get }
    
    init?(_ metadataValue: Logger.MetadataValue)
}

extension LossLessMetadataValueConvertible where Self: Swift.LosslessStringConvertible {
    public var metadataValue: Logger.MetadataValue {
        return .string(description)
    }
    
    public init?(_ metadataValue: Logger.MetadataValue) {
        switch metadataValue {
        case .string(let string):
            self.init(string)
        default:
            return nil
        }
    }
}

extension Bool: LossLessMetadataValueConvertible { }

extension Float: LossLessMetadataValueConvertible { }
extension Double: LossLessMetadataValueConvertible { }

extension String: LossLessMetadataValueConvertible { }

extension Int: LossLessMetadataValueConvertible { }
extension Int8: LossLessMetadataValueConvertible { }
extension Int16: LossLessMetadataValueConvertible { }
extension Int32: LossLessMetadataValueConvertible { }
extension Int64: LossLessMetadataValueConvertible { }

extension UInt: LossLessMetadataValueConvertible { }
extension UInt8: LossLessMetadataValueConvertible { }
extension UInt16: LossLessMetadataValueConvertible { }
extension UInt32: LossLessMetadataValueConvertible { }
extension UInt64: LossLessMetadataValueConvertible { }

extension Array: LossLessMetadataValueConvertible where Element: LossLessMetadataValueConvertible {
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

extension Dictionary: LossLessMetadataValueConvertible where Key == String, Value: LossLessMetadataValueConvertible {
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


extension Date: LossLessMetadataValueConvertible {
    public var metadataValue: Logger.MetadataValue {
        .string(timeIntervalSince1970.description)
    }

    public init?(_ metadataValue: Logger.MetadataValue) {
        switch metadataValue {
        case .string(let s):
            if let timeInterval = TimeInterval(s) {
                self = Date(timeIntervalSince1970: timeInterval)
            }
            return nil
        default:
            return nil
        }
    }
}

extension OperatingSystemVersion: LossLessMetadataValueConvertible {
    public var metadataValue: Logger.MetadataValue {
        .array([majorVersion, minorVersion, patchVersion].map { $0.metadataValue })
    }
    
    public init?(_ metadataValue: Logger.MetadataValue) {
        switch metadataValue {
        case .array(let values):
            let versions = values.compactMap { Int($0) }
            guard versions.count == 3 else { return nil }
            self.init(majorVersion: versions[0], minorVersion: versions[1], patchVersion: versions[2])
        default:
            return nil
        }
    }
}

extension StackFrame: LossLessMetadataValueConvertible {
    public var metadataValue: Logger.MetadataValue {
        .array([moduleName, functionName].map { $0.metadataValue })
    }
    
    public init?(_ metadataValue: Logger.MetadataValue) {
        switch metadataValue {
        case .array(let values):
            let components = values.compactMap { value -> String? in
                switch value {
                case .string(let s):    return s
                default:                return nil
                }
            }
            guard components.count == 2 else { return nil }
            self.init(moduleName: components[0], functionName: components[1])
        default:
            return nil
        }
    }
}
