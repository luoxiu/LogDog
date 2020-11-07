import Foundation

#if canImport(Compression)
    import Compression

    public extension LogSink where Self.Output == Data {
        @available(iOS 9.0, macOS 10.11, tvOS 9.0, watchOS 2.0, *)
        func compress(_ algorithm: compression_algorithm) -> LogSinks.Concat<Self, LogFormatters.Compress> {
            self + LogFormatters.Compress(algorithm)
        }
    }

    public extension LogFormatters {
        @available(iOS 9.0, macOS 10.11, tvOS 9.0, watchOS 2.0, *)
        struct Compress: LogFormatter {
            public typealias Input = Data
            public typealias Output = Data

            public let algorithm: compression_algorithm

            public init(_ algorithm: compression_algorithm) {
                self.algorithm = algorithm
            }

            public func format(_ record: LogRecord<Data>) throws -> Data? {
                if record.output.isEmpty {
                    return record.output
                }

                return LogDog.compress(input: record.output, algorithm: algorithm)
            }
        }
    }

    // https://www.raywenderlich.com/7181017-unsafe-swift-using-pointers-and-interacting-with-c

    @available(iOS 9.0, macOS 10.11, tvOS 9.0, watchOS 2.0, *)
    private func compress(input: Data,
                          algorithm: compression_algorithm) -> Data?
    {
        let operation = COMPRESSION_STREAM_ENCODE
        let flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)

        let streamPointer = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
        defer {
            streamPointer.deallocate()
        }

        var stream = streamPointer.pointee

        var status = compression_stream_init(&stream, operation, algorithm)

        guard status != COMPRESSION_STATUS_ERROR else {
            return nil
        }

        defer {
            compression_stream_destroy(&stream)
        }

        let bufferSize = 2 * 1024

        let dstSize = bufferSize
        let dstPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstSize)

        defer {
            dstPointer.deallocate()
        }

        return input.withUnsafeBytes { srcRawBufferPointer -> Data? in
            var output = Data()

            let srcBufferPoint = srcRawBufferPointer.bindMemory(to: UInt8.self)

            guard let srcPointer = srcBufferPoint.baseAddress else {
                return nil
            }

            stream.src_ptr = srcPointer
            stream.src_size = input.count
            stream.dst_ptr = dstPointer
            stream.dst_size = dstSize

            while status == COMPRESSION_STATUS_OK {
                status = compression_stream_process(&stream, flags)

                switch status {
                case COMPRESSION_STATUS_OK:
                    output.append(dstPointer, count: dstSize)
                    stream.dst_ptr = dstPointer
                    stream.dst_size = dstSize

                case COMPRESSION_STATUS_ERROR:
                    return nil
                case COMPRESSION_STATUS_END:

                    output.append(dstPointer, count: stream.dst_ptr - dstPointer)

                default:
                    return nil
                }
            }

            return output
        }
    }

#endif
