import Foundation

public struct CryptoLogProcessor: LogProcessor {

    public typealias Input = Data
    public typealias Output = Data
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public let cipher: Cipher

    public init(cipher: Cipher) {
        self.cipher = cipher
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Data>) throws -> ProcessedLogEntry<Data> {
        logEntry.map { data in
            let encrypted = try self.cipher.encrypt(Array(data))
            return Data(encrypted)
        }
    }
}
