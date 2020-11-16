@testable import LogDog
import XCTest

class TestLogAppenderTests: XCTestCase {
    func testAppend() {
        let stream = TestStream()
        let appender = TextLogAppender(stream)

        do {
            try appender.append(LogRecord<String>(LogEntry.fake(), "a"))
            try appender.append(LogRecord<String>(LogEntry.fake(), "b"))
            try appender.append(LogRecord<String>(LogEntry.fake(), "c"))

            XCTAssertEqual(stream.buffer, "abc")
        } catch {
            XCTFail()
        }
    }
}
