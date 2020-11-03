import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CompressLogFormatter: LogFormatter {
    
    public typealias CompressionAlgorithm = NSData.CompressionAlgorithm
    
    public typealias Input = Data
    public typealias Output = Data
    
    public let compressionAlgorithm: CompressionAlgorithm
    
    public init(compressionAlgorithm: CompressionAlgorithm) {
        self.compressionAlgorithm = compressionAlgorithm
    }
    
    public func format(_ record: LogRecord<Data>) throws -> Data? {
        try (record.output as NSData).compressed(using: compressionAlgorithm) as Data
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension LogFormatter where Self.Output == Data {
    
    func compress(using compressionAlgorithm: CompressLogFormatter.CompressionAlgorithm) -> CombineLogFormatter<Self, CompressLogFormatter> {
        self + CompressLogFormatter(compressionAlgorithm: compressionAlgorithm)
    }
}
