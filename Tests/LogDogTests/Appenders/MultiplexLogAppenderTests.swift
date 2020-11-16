@testable import LogDog
import XCTest

class MultiplexLogAppenderTests: XCTestCase {
    func testAppend() {
        let streamA = TestStream()
        let appenderA = TextLogAppender(streamA)

        let streamB = TestStream()
        let appenderB = TextLogAppender(streamB)

        let appender = MultiplexLogAppender(appenderA, appenderB)

        do {
            try appender.append(LogRecord<String>(LogEntry.fake(), "a"))
            try appender.append(LogRecord<String>(LogEntry.fake(), "b"))
            try appender.append(LogRecord<String>(LogEntry.fake(), "c"))

            XCTAssertEqual(streamA.buffer, "abc")
            XCTAssertEqual(streamB.buffer, "abc")
        } catch {
            XCTFail()
        }
    }
}
