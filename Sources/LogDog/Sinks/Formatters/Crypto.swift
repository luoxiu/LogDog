import Foundation

#if canImport(CryptoKit)
    import CryptoKit

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public extension LogSink where Self.Output == Data {
        func encrypt(using key: SymmetricKey, cipher: LogFormatters.Crypto.Cipher = .ChaChaPoly) -> LogSinks.Concat<Self, LogFormatters.Crypto> {
            self + LogFormatters.Crypto(key: key, cipher: cipher)
        }
    }

    public extension LogFormatters {
        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        struct Crypto: LogSink {
            public typealias Input = Data
            public typealias Output = Data

            public enum Cipher {
                case AES
                case ChaChaPoly
            }

            public let key: SymmetricKey
            public let cipher: Cipher

            public init(key: SymmetricKey, cipher: Cipher) {
                self.key = key
                self.cipher = cipher
            }

            public func sink(_ record: LogRecord<Data>, next: @escaping LogSinkNext<Data>) {
                record.sink(before: next) { record in
                    switch cipher {
                    case .AES:
                        return try AES.GCM.seal(record.output, using: key).combined
                    case .ChaChaPoly:
                        return try ChaChaPoly.seal(record.output, using: key).combined
                    }
                }
            }
        }
    }
#endif
