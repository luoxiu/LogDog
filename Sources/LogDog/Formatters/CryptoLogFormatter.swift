import Foundation
import CryptoKit

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CryptoLogFormatter: LogFormatter {
    
    public typealias Input = Data
    public typealias Output = Data
    
    public let key: SymmetricKey

    public init(key: SymmetricKey) {
        self.key = key
    }
    
    public func format(_ record: LogRecord<Data>) throws -> Data? {
        let box = try ChaChaPoly.seal(record.output, using: key)
        return box.combined
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension LogFormatter where Self.Output == Data {
    
    func encrypt(using key: SymmetricKey) -> CombineLogFormatter<Self, CryptoLogFormatter> {
        self + CryptoLogFormatter(key: key)
    }
}
