
@testable import LogDog
import XCTest

class LogSinksConcatTests: XCTestCase {
    func testConcat() {
        let sinkA = AnyLogSink<Int, Int> {
            $0.parameters[0] = 0
        } sink: { record, next in
            record.sink(next: next) { record in
                record.output + 1
            }
        }

        let sinkB = AnyLogSink<Int, Int> {
            $0.parameters[1] = 1
        } sink: { record, next in
            record.sink(next: next) { record in
                record.output + 1
            }
        }

        let concat = sinkA.concat(sinkB)

        var entry = LogEntry.fake()
        concat.beforeSink(&entry)
        XCTAssertEqual(entry.parameters[0] as? Int, 0)
        XCTAssertEqual(entry.parameters[1] as? Int, 1)

        let record = LogRecord<Int>(entry, 0)
        concat.sink(record) { result in
            switch result {
            case .failure:
                XCTFail()
            case let .success(record):
                XCTAssertEqual(record?.output, 2)
            }
        }
    }

    func testNil() {
        let sinkA = AnyLogSink<Int, Int> { record, next in
            record.sink(next: next) { _ in
                nil
            }
        }

        let sinkB = AnyLogSink<Int, Int> { record, next in
            record.sink(next: next) { record in
                record.output + 1
            }
        }

        let concat = sinkA.concat(sinkB)

        let record = LogRecord<Int>(.fake(), 0)
        concat.sink(record) { result in
            switch result {
            case .failure:
                XCTFail()
            case let .success(record):
                XCTAssertNil(record)
            }
        }
    }

    func testThrow() {
        let sinkA = AnyLogSink<Int, Int> { record, next in
            record.sink(next: next) { _ in
                throw LogError.ex
            }
        }

        let sinkB = AnyLogSink<Int, Int> { record, next in
            record.sink(next: next) { record in
                record.output + 1
            }
        }

        let concat = sinkA.concat(sinkB)

        let record = LogRecord<Int>(.fake(), 0)
        concat.sink(record) { result in
            switch result {
            case let .failure(error):
                guard case LogError.ex = error else {
                    XCTFail()
                    return
                }
            case .success:
                XCTFail()
            }
        }
    }
}
