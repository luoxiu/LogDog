@testable import LogDog
import XCTest

class LogSinksSinkOnTests: XCTestCase {
    func testSinkOn() {
        let sinkA = AnyLogSink<Int, Int> { record, next in
            record.sink(next: next) { record in
                XCTAssertTrue(Thread.isMainThread)
                return record.output + 1
            }
        }

        let sinkB = AnyLogSink<Int, Int> { record, next in
            record.sink(next: next) { record in
                XCTAssertFalse(Thread.isMainThread)
                return record.output + 1
            }
        }

        let queue = DispatchQueue(label: "log")
        let concat = sinkA.sink(on: queue).concat(sinkB)

        let record = LogRecord<Int>(.fake(), 0)

        let expect = XCTestExpectation()

        concat.sink(record) { _ in
            expect.fulfill()
        }

        wait(for: [expect], timeout: .greatestFiniteMagnitude)
    }
}
