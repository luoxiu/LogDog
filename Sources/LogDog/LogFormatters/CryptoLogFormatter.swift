import Foundation
import CryptoKit

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CryptoLogFormatter: LogFormatter {
    
    public typealias Input = Data
    public typealias Output = Data
    
    public var context: [String : () -> Logger.MetadataValue?] = [:]
    
    public let key: SymmetricKey

    public init(key: SymmetricKey) {
        self.key = key
    }
    
    public func format(_ logEntry: ProcessedLogEntry<Data>) throws -> ProcessedLogEntry<Data> {
        try logEntry.map { data in
            let box = try ChaChaPoly.seal(data, using: key)
            return box.combined
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension LogFormatter where Self.Output == Data {
    
    func encrypt(using key: SymmetricKey) -> MultiplexLogFormatter<Self, CryptoLogFormatter> {
        self + CryptoLogFormatter(key: key)
    }
}
