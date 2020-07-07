import Foundation
@_exported import CryptoSwift

public struct CryptoLogFormatter: LogFormatter {
    
    public typealias I = Data
    public typealias O = Data
    
    public let cipher: Cipher

    public init(cipher: Cipher) {
        self.cipher = cipher
    }
    
    public func format(_ log: FormattedLogEntry<Data>) throws -> FormattedLogEntry<Data> {
        try log.map {
            let encrypted = try cipher.encrypt(Array($0))
            return Data(encrypted)
        }
    }
}


