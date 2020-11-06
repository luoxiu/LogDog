import CryptoKit
import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension LogSink where Self.Output == Data {
    func encrypt(using key: SymmetricKey) -> LogSinks.Concat<Self, LogFormatters.Crypto> {
        concat(LogFormatters.Crypto(key: key))
    }
}

public extension LogFormatters {
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    struct Crypto: LogFormatter {
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
}
