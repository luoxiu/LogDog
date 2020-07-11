import Foundation

open class ZipLogPorcessor: LogProcessor<Data, Data> {
    
    public let compressionLevel: CompressionLevel
    
    public init(_ compressionLevel: CompressionLevel) {
        self.compressionLevel = compressionLevel
        super.init {
            try $0.map {
                try $0.gzipped(level: compressionLevel)
            }
        }
    }
}

