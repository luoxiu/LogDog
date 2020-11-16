@testable import LogDog
import XCTest

class AnyLogAppenderTests: XCTestCase {
    func testBody() {
        var output: [Int] = []

        let appender = AnyLogAppender { (record: LogRecord<Int>) in
            output.append(record.output)
        }

        do {
            try appender.append(LogRecord<Int>(LogEntry.fake(), 1))
            try appender.append(LogRecord<Int>(LogEntry.fake(), 2))
            try appender.append(LogRecord<Int>(LogEntry.fake(), 3))

            XCTAssertEqual(output, [1, 2, 3])
        } catch {
            XCTFail()
        }
    }

    func testAppender() {
        let underlying = MemoryLogAppender<Int>()
        let appender = AnyLogAppender(underlying)

        do {
            try appender.append(LogRecord<Int>(.fake(), 1))
            try appender.append(LogRecord<Int>(.fake(), 2))
            try appender.append(LogRecord<Int>(.fake(), 3))

            XCTAssertEqual(underlying.snapshot.map { $0.output },
                           [1, 2, 3])
        } catch {
            XCTFail()
        }
    }
}
