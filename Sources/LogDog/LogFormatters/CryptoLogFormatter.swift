import struct Foundation.Data

open class CryptoLogFormatter: LogFormatter<Data, Data> {
    
    public let cipher: Cipher

    public init(cipher: Cipher) {
        self.cipher = cipher
        
        super.init {
            try $0.map {
                let encrypted = try cipher.encrypt(Array($0))
                return Data(encrypted)
            }
        }
    }
}


