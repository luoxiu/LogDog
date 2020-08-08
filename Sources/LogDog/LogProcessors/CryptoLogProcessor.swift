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
        try logEntry.map { data in
            let encrypted = try cipher.encrypt(Array(data))
            return Data(encrypted)
        }
    }
}

public extension LogProcessor where Self.Output == Data {
    
    func encrypt(using cipher: Cipher) -> MultiplexLogProcessor<Self, CryptoLogProcessor> {
        self + CryptoLogProcessor(cipher: cipher)
    }
}
