@testable import LogDog
import XCTest

class MultiplexLogAppenderTests: XCTestCase {
    func testAppend() {
        let streamA = TextStream()
        let appenderA = TextLogAppender(streamA)

        let streamB = TextStream()
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
