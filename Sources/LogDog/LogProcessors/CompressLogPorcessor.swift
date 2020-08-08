import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct CompressLogProcessor: LogProcessor {
    
    public typealias CompressionAlgorithm = NSData.CompressionAlgorithm
    
    public typealias Input = Data
    public typealias Output = Data
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public let compressionAlgorithm: CompressionAlgorithm
    
    public init(compressionAlgorithm: CompressionAlgorithm) {
        self.compressionAlgorithm = compressionAlgorithm
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Data>) throws -> ProcessedLogEntry<Data> {
        try logEntry.map { data in
            try NSMutableData(data: data).compressed(using: self.compressionAlgorithm) as Data
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension LogProcessor where Self.Output == Data {
    
    func compress(using compressionAlgorithm: CompressLogProcessor.CompressionAlgorithm) -> MultiplexLogProcessor<Self, CompressLogProcessor> {
        self + CompressLogProcessor(compressionAlgorithm: compressionAlgorithm)
    }
}
