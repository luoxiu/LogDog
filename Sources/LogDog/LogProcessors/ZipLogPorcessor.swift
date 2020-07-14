import Foundation

public struct ZipLogPorcessor: LogProcessor {
    
    public typealias Input = Data
    public typealias Output = Data
    
    public var contextCaptures: [String : () -> LossLessMetadataValueConvertible?] = [:]
    
    public let compressionLevel: CompressionLevel
    
    public init(_ compressionLevel: CompressionLevel) {
        self.compressionLevel = compressionLevel
    }
    
    public func process(_ logEntry: ProcessedLogEntry<Data>) throws -> ProcessedLogEntry<Data> {
        logEntry.map { data in
            try data.gzipped(level: self.compressionLevel)
        }
    }
}

