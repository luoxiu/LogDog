@testable import LogDog
import XCTest

class MemoryLogAppenderTests: XCTestCase {
    func testAppend() {
        let appender = MemoryLogAppender<Int>()

        do {
            try appender.append(LogRecord<Int>(.fake(), 1))
            try appender.append(LogRecord<Int>(.fake(), 2))
            try appender.append(LogRecord<Int>(.fake(), 3))

            XCTAssertEqual(appender.snapshot.map(\.output),
                           [1, 2, 3])
        } catch {
            XCTFail()
        }
    }
}
