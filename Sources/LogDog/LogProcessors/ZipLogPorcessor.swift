import Foundation

public struct ZipLogPorcessor: LogProcessor {
    
    public typealias Input = Data
    public typealias Output = Data
    
    public var contextCaptures: [String : (LogEntry) -> LossLessMetadataValueConvertible?] = [:]
    
    public let compressionLevel: CompressionLevel
    
    public init(compressionLevel: CompressionLevel) {
        self.compressionLevel = compressionLevel
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Data>) throws -> ProcessedLogEntry<Data> {
        try logEntry.map { data in
            try data.gzipped(level: compressionLevel)
        }
    }
}

public extension LogProcessor where Self.Output == Data {
    
    func zip(using compressionLevel: CompressionLevel) -> CombineLogProcessor<Self.Input, Data> {
        self + ZipLogPorcessor(compressionLevel: compressionLevel)
    }
}
