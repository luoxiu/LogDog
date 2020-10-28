import Foundation
import CryptoKit

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CryptoLogProcessor: LogProcessor {
    
    public enum Cipher {
        case AES
        case ChaChaPoly
    }
    
    public typealias Input = Data
    public typealias Output = Data
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public let key: SymmetricKey

    public init(key: SymmetricKey) {
        self.key = key
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Data>) throws -> ProcessedLogEntry<Data> {
        try logEntry.map { data in
            let box = try ChaChaPoly.seal(data, using: key)
            return box.combined
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension LogProcessor where Self.Output == Data {
    
    func encrypt(using key: SymmetricKey) -> MultiplexLogProcessor<Self, CryptoLogProcessor> {
        self + CryptoLogProcessor(key: key)
    }
}
