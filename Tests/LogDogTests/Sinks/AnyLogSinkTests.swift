@testable import LogDog
import XCTest

class AnyLogSinkTests: XCTestCase {
    func testBody() {
        let sink = AnyLogSink<Int, Int> { entry in
            entry.parameters[0] = 0
        } sink: { record, next in
            print(record.entry.parameters)
            record.sink(next: next) { record in
                record.output + 1
            }
        }

        var entry = LogEntry.fake()
        sink.beforeSink(&entry)
        XCTAssertEqual(entry.parameters[0] as? Int, 0)

        let record = LogRecord(.fake(), 0)
        sink.sink(record) { result in
            switch result {
            case .failure:
                XCTFail()
            case let .success(record):
                XCTAssertEqual(record?.output, 1)
            }
        }
    }

    func testSink() {
        let prefix = LogSinks.Prefix<String>(prefix: "x")

        let record = LogRecord(.fake(), "q")
        AnyLogSink(prefix).sink(record) { result in
            switch result {
            case .failure:
                XCTFail()
            case let .success(record):
                XCTAssertEqual(record?.output, "xq")
            }
        }
    }
}
