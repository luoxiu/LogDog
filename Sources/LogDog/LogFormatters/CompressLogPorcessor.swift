import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CompressLogFormatter: LogFormatter {
    
    public typealias CompressionAlgorithm = NSData.CompressionAlgorithm
    
    public typealias Input = Data
    public typealias Output = Data
    
    public var context: [String : () -> Logger.MetadataValue?] = [:]
    
    public let compressionAlgorithm: CompressionAlgorithm
    
    public init(compressionAlgorithm: CompressionAlgorithm) {
        self.compressionAlgorithm = compressionAlgorithm
    }
    
    public func format(_ logEntry: ProcessedLogEntry<Data>) throws -> ProcessedLogEntry<Data> {
        try logEntry.map { data in
            try NSMutableData(data: data).compressed(using: self.compressionAlgorithm) as Data
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension LogFormatter where Self.Output == Data {
    
    func compress(using compressionAlgorithm: CompressLogFormatter.CompressionAlgorithm) -> MultiplexLogFormatter<Self, CompressLogFormatter> {
        self + CompressLogFormatter(compressionAlgorithm: compressionAlgorithm)
    }
}
